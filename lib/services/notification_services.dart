import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;

import 'package:desktoasts/desktoasts.dart'
    if (dart.library.html) 'package:deliver/web_classes/web_desktoasts.dart'
    as windows_notify;
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:desktop_window/desktop_window.dart';

abstract class Notifier {
  notify(MessageBrief message);

  cancel(int id, String roomId);

  cancelAll();

  cancelById(int id);
}

MessageBrief synthesize(MessageBrief mb) {
  if (mb.text != null && mb.text!.isNotEmpty) {
    return mb.copyWith(
        text:
            BoldTextParser.transformer(ItalicTextParser.transformer(mb.text!)));
  }

  return mb;
}

class NotificationServices {
  final _audioService = GetIt.I.get<AudioService>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _notifier = GetIt.I.get<Notifier>();

  void showNotification(pro.Message message, {String? roomName}) async {
    final mb = (await extractMessageBrief(_i18n, _roomRepo, _authRepo, message))
        .copyWith(roomName: roomName);
    if (mb.ignoreNotification!) return;

    // TODO change place of synthesizer if we want more styled texts in android
    _notifier.notify(synthesize(mb));
  }

  void cancelRoomNotifications(String roomUid) {
    _notifier.cancel(roomUid.hashCode, roomUid);
  }

  void cancelNotificationById(int id) {
    _notifier.cancelById(id);
  }

  void cancelAllNotifications() {
    _notifier.cancelAll();
  }

  void playSoundIn() async {}

  void playIncomingMsg() async {}

  void playSoundOut() {
    _audioService.playSoundOut();
  }
}

class FakeNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id, String roomId) {}

  @override
  cancelAll() {}

  @override
  cancelById(int id) {}
}

class IOSNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id, String roomId) {}

  @override
  cancelAll() {}

  @override
  cancelById(int id) {}
}

class WindowsNotifier implements Notifier {
  final _routingService = GetIt.I.get<RoutingService>();
  final windows_notify.ToastService _windowsNotificationServices =
      windows_notify.ToastService(
    appName: APPLICATION_NAME,
    companyName: "deliver.co.ir",
    productName: "deliver",
  );

  @override
  notify(MessageBrief message) async {
    if (message.ignoreNotification!) return;
    var _avatarRepo = GetIt.I.get<AvatarRepo>();
    var fileRepo = GetIt.I.get<FileRepo>();
    final _fileServices = GetIt.I.get<FileService>();
    final _logger = GetIt.I.get<Logger>();
    try {
      Avatar? lastAvatar =
          await _avatarRepo.getLastAvatar(message.roomUid!, false);
      if (lastAvatar != null && lastAvatar.fileId != null) {
        String? file = await fileRepo.getFile(
            lastAvatar.fileId!, lastAvatar.fileName!,
            thumbnailSize: ThumbnailSize.medium);
        windows_notify.Toast toast = windows_notify.Toast(
            type: windows_notify.ToastType.imageAndText02,
            title: message.roomName!,
            subtitle: createNotificationTextFromMessageBrief(message),
            image: File(file!));
        _windowsNotificationServices.show(toast);
        _windowsNotificationServices.stream.listen((event) {
          if (event is windows_notify.ToastActivated) {
            _routingService.openRoom(lastAvatar.uid);
          }
        });
      } else {
        var deliverIcon = await _fileServices.getDeliverIcon();
        if (deliverIcon != null && deliverIcon.existsSync()) {
          windows_notify.Toast toast = windows_notify.Toast(
            type: windows_notify.ToastType.imageAndText02,
            title: message.roomName!,
            image: deliverIcon,
            subtitle: createNotificationTextFromMessageBrief(message),
          );
          _windowsNotificationServices.show(toast);
          _windowsNotificationServices.stream.listen((event) {
            if (event is windows_notify.ToastActivated) {
              if (lastAvatar != null) {
                _routingService.openRoom(lastAvatar.uid);
                DesktopWindow.focus();
              }
            }
          });
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancel(int id, String roomId) {}

  @override
  cancelAll() {}

  @override
  cancelById(int id) {}
}

class WebNotifier implements Notifier {
  @override
  cancel(int id, String roomId) {}

  @override
  cancelById(int id) {}

  @override
  cancelAll() {}

  @override
  notify(MessageBrief message) {
    js.context.callMethod("showNotification",
        [message.roomName, createNotificationTextFromMessageBrief(message)]);
  }
}

class LinuxNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      LinuxFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  cancelById(int id) {}

  LinuxNotifier() {
    var notificationSetting =
        const LinuxInitializationSettings(defaultActionName: "");

    _flutterLocalNotificationsPlugin.initialize(notificationSetting,
        onSelectNotification: (room) {
      if (room != null && room.isNotEmpty) {
        _routingService.openRoom(room);
      }
      return;
    });
  }

  @override
  notify(MessageBrief message) async {
    if (message.ignoreNotification!) return;

    LinuxNotificationIcon icon = AssetsLinuxIcon(
        'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');

    var la = await _avatarRepo.getLastAvatar(message.roomUid!, false);

    if (la != null && la.fileId != null) {
      var path = await _fileRepo.getFileIfExist(la.fileId!, la.fileName!,
          thumbnailSize: ThumbnailSize.medium);

      if (path != null && path.isNotEmpty) {
        icon = AssetsLinuxIcon(path);
      }
    }

    var platformChannelSpecifics = LinuxNotificationDetails(icon: icon);

    _flutterLocalNotificationsPlugin.show(message.roomUid!.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: platformChannelSpecifics,
        payload: message.roomUid!.asString());
  }

  @override
  cancel(int id, String roomId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }
}

class AndroidNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      AndroidFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'notifications', // id
      'Notifications', // title
      description: 'All notifications of application.', // description
      importance: Importance.high,
      groupId: "all_group");

  AndroidNotifier() {
    _flutterLocalNotificationsPlugin.createNotificationChannel(channel);

    var notificationSetting =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    _flutterLocalNotificationsPlugin.initialize(notificationSetting,
        onSelectNotification: androidOnSelectNotification);
    androidDidNotificationLaunchApp();
  }

  androidDidNotificationLaunchApp() async {
    final notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      androidOnSelectNotification(notificationAppLaunchDetails!.payload);
    }
  }

  Future<dynamic> androidOnSelectNotification(room) async {
    if (room != null && room.isNotEmpty) {
      _routingService.openRoom(room);
    }
    return;
  }

  @override
  cancelById(int id) {
    _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  notify(MessageBrief message) async {
    if (message.ignoreNotification!) return;

    AndroidBitmap<Object>? largeIcon;
    String selectedNotificationSound = "that_was_quick";
    var selectedSound =
        await _roomRepo.getRoomCustomNotification(message.roomUid!.asString());
    var la = await _avatarRepo.getLastAvatar(message.roomUid!, false);
    if (la != null && la.fileId != null && la.fileName != null) {
      var path = await _fileRepo.getFileIfExist(la.fileId!, la.fileName!,
          thumbnailSize: ThumbnailSize.medium);

      if (path != null && path.isNotEmpty) {
        largeIcon = FilePathAndroidBitmap(path);
      }
    }
    if (selectedSound != null) {
      if (selectedSound != "-") {
        selectedNotificationSound = selectedSound;
      }
    }

    InboxStyleInformation inboxStyleInformation =
        const InboxStyleInformation([], contentTitle: 'new messages');

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            selectedNotificationSound + message.roomUid!.asString(),
            channel.name,
            channelDescription: channel.description,
            styleInformation: inboxStyleInformation,
            groupKey: channel.groupId,
            playSound: true,
            sound:
                RawResourceAndroidNotificationSound(selectedNotificationSound),
            setAsGroupSummary: true);
    _flutterLocalNotificationsPlugin.show(message.roomUid.hashCode, 'Attention', 'new messages',
        notificationDetails: androidNotificationDetails);

    var platformChannelSpecifics = AndroidNotificationDetails(
      selectedNotificationSound + message.roomUid!.asString(),
      channel.name,
      channelDescription: channel.description,
      groupKey: channel.groupId,
      largeIcon: largeIcon,
      styleInformation: const BigTextStyleInformation(''),
      playSound: true,
      sound: RawResourceAndroidNotificationSound(selectedNotificationSound),
    );
    _flutterLocalNotificationsPlugin.show(
        message.roomUid!.asString().hashCode + message.id!,
        message.roomName,
        createNotificationTextFromMessageBrief(message),
        notificationDetails: platformChannelSpecifics,
        payload: message.roomUid!.asString());
  }

  @override
  cancel(int id, String roomId) async {
    try {
      List<ActiveNotification>? activeNotification =
          await _flutterLocalNotificationsPlugin.getActiveNotifications();
      for (var element in activeNotification!) {
        if (element.channelId!.contains(roomId) && element.id != 0) {
          await _flutterLocalNotificationsPlugin.cancel(element.id);
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }
}

class MacOSNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      MacOSFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  MacOSNotifier() {
    var macNotificationSetting = const MacOSInitializationSettings();

    _flutterLocalNotificationsPlugin.initialize(macNotificationSetting,
        onSelectNotification: (room) {
      if (room != null && room.isNotEmpty) {
        _routingService.openRoom(room);
      }
      return;
    });
  }

  @override
  notify(MessageBrief message) async {
    if (message.ignoreNotification!) return;

    List<MacOSNotificationAttachment> attachments = [];

    var la = await _avatarRepo.getLastAvatar(message.roomUid!, false);

    if (la != null) {
      var path = await _fileRepo.getFileIfExist(la.fileId!, la.fileName!,
          thumbnailSize: ThumbnailSize.medium);

      if (path != null && path.isNotEmpty) {
        attachments.add(MacOSNotificationAttachment(path));
      }
    }

    var macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(attachments: attachments, badgeNumber: 0);

    _flutterLocalNotificationsPlugin.show(message.roomUid!.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: macOSPlatformChannelSpecifics,
        payload: message.roomUid!.asString());
  }

  @override
  cancel(int id, String roomId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancelById(int id) {}
}

String createNotificationTextFromMessageBrief(MessageBrief mb) {
  var text = "";
  if (!(mb.roomUid!.isBot() || mb.roomUid!.isUser()) &&
      mb.senderIsAUserOrBot!) {
    text += "${mb.sender!.trim()}: ";
  }
  if (mb.typeDetails!.isNotEmpty) {
    text += mb.typeDetails!;
  }
  if (mb.typeDetails!.isNotEmpty && mb.text!.isNotEmpty) {
    text += ", ";
  }
  if (mb.text!.isNotEmpty) {
    text += mb.text!;
  }

  return text;
}
