import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

abstract class Notifier {
  notify(MessageBrief message);

  cancel(int id, String roomId);

  cancelAll();
}

MessageBrief synthesize(MessageBrief mb) {
  if (mb.text != null && mb.text.isNotEmpty) {
    return mb.copyWith(
        text:
            BoldTextParser.transformer(ItalicTextParser.transformer(mb.text)));
  }

  return mb;
}

class NotificationServices {
  final _audioService = GetIt.I.get<AudioService>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _notifier = GetIt.I.get<Notifier>();

  void showNotification(pro.Message message, {String roomName}) async {
    final mb = (await extractMessageBrief(_i18n, _roomRepo, _authRepo, message))
        .copyWith(roomName: roomName);
    if (mb.ignoreNotification) return;

    // TODO change place of synthesizer if we want more styled texts in android
    _notifier.notify(synthesize(mb));
  }

  void cancelRoomNotifications(String roomUid) {
    _notifier.cancel(roomUid.hashCode, roomUid);
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
}

class IOSNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id, String roomId) {}

  @override
  cancelAll() {}
}

class WindowsNotifier implements Notifier {
  final _routingService = GetIt.I.get<RoutingService>();
  ToastService _windowsNotificationServices = new ToastService(
    appName: APPLICATION_NAME,
    companyName: "deliver.co.ir",
    productName: "deliver",
  );

  @override
  notify(MessageBrief message) async {
    if (message.ignoreNotification) return;
    var _avatarRepo = GetIt.I.get<AvatarRepo>();
    var fileRepo = GetIt.I.get<FileRepo>();
    final _fileServices = GetIt.I.get<FileService>();

    final _logger = GetIt.I.get<Logger>();
    try {
      var lastAvatar = await _avatarRepo.getLastAvatar(message.roomUid, false);
      if (lastAvatar != null && lastAvatar.fileId != null) {
        var file = await fileRepo.getFile(
            lastAvatar.fileId, lastAvatar.fileName,
            thumbnailSize: ThumbnailSize.medium);
        Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: message.roomName,
            subtitle: createNotificationTextFromMessageBrief(message),
            image: file);
        _windowsNotificationServices.show(toast);
        _windowsNotificationServices.stream?.listen((event) {
          if (event is ToastActivated) {
            if (lastAvatar.uid != null)
              _routingService.openRoom(lastAvatar.uid);
          }
        });
      } else {
        var deliverIcon = await _fileServices.getDeliverIcon();
        if (deliverIcon != null && deliverIcon.existsSync()) {
          Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: message.roomName,
            image: deliverIcon,
            subtitle: createNotificationTextFromMessageBrief(message),
          );
          _windowsNotificationServices.show(toast);
          _windowsNotificationServices.stream?.listen((event) {
            if (event is ToastActivated) {
              if (lastAvatar.uid != null)
                _routingService.openRoom(lastAvatar.uid);
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
}

class LinuxNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      LinuxFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  LinuxNotifier() {
    var notificationSetting =
        new LinuxInitializationSettings(defaultActionName: "");

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
    if (message.ignoreNotification) return;

    LinuxNotificationIcon icon = AssetsLinuxIcon(
        'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');

    var la = await _avatarRepo.getLastAvatar(message.roomUid, false);

    if (la != null) {
      var f = await _fileRepo.getFileIfExist(la.fileId, la.fileName,
          thumbnailSize: ThumbnailSize.medium);

      if (f != null && f.path.isNotEmpty) {
        icon = AssetsLinuxIcon(f.path);
      }
    }

    var platformChannelSpecifics = LinuxNotificationDetails(icon: icon);

    _flutterLocalNotificationsPlugin.show(message.roomUid.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: platformChannelSpecifics,
        payload: message.roomUid.asString());
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
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notifications', // id
      'Notifications', // title
      description: 'All notifications of application.', // description
      importance: Importance.high,
      groupId: "all_group");

  AndroidNotifier() {
    print("notifir");
    AwesomeNotifications().initialize(null, []);
    AwesomeNotifications().actionStream.listen((receivedNotification) {
      print(receivedNotification);

      int messageId = int.parse(receivedNotification.payload['id']);
      Uid uid = receivedNotification.payload['uid'].asUid();
      MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
      if (!StringUtils.isNullOrEmpty(receivedNotification.buttonKeyInput)) {
        AwesomeNotifications().cancel(receivedNotification.id);
        messageRepo.sendTextMessage(
          uid,
          receivedNotification.buttonKeyInput,
          replyId: messageId,
        );
      }
      if (receivedNotification.buttonKeyPressed == "READ") {
        messageRepo.sendSeen(messageId, uid);
        _roomRepo.saveMySeen(Seen(
            uid: receivedNotification.payload['uid'], messageId: messageId));
      }
      if (StringUtils.isNullOrEmpty(receivedNotification.buttonKeyInput) || StringUtils.isNullOrEmpty(receivedNotification.buttonKeyPressed) ) {
        print("open");
        _routingService.openRoom(receivedNotification.payload['uid']);
      }
    });
  }

  @override
  notify(MessageBrief message) async {
    print(message.type);
    if (message.ignoreNotification) return;
    String finalFilePath;
    Room room = await _roomRepo.getRoom(message.roomUid.asString());
    String selectedNotificationSound = "that_was_quick";
    var selectedSound =
        await _roomRepo.getRoomCustomNotification(message.roomUid.asString());

    var la = await _avatarRepo.getLastAvatar(message.roomUid, false);
    if (la != null) {
      var f = await _fileRepo.getFileIfExist(la.fileId, la.fileName,
          thumbnailSize: ThumbnailSize.medium);

      if (f != null && f.path.isNotEmpty) {
        String filePath = f.path;
        filePath = filePath.replaceFirst('/', '');
        finalFilePath = 'file://' + (filePath);
      }
    }
    if (selectedSound != null) {
      if (selectedSound != "-") {
        selectedNotificationSound = selectedSound;
      }
    }
    AwesomeNotifications().setChannel(
      // set the icon to null if you want to use the default app icon
      NotificationChannel(
          channelKey: message.roomUid.toString() + selectedNotificationSound,
          channelName: channel.name,
          channelDescription: channel.description,
          ledColor: Colors.white,
          playSound: true,
          defaultColor: Colors.blueAccent,
          soundSource: 'resource://raw/${selectedNotificationSound}',
          groupKey: message.roomUid.node.toString()),
    );
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: message.roomUid.asString().hashCode +
              message.text.toString().hashCode +
              Random().nextInt(10000),
          channelKey: message.roomUid.toString() + selectedNotificationSound,
          title: message.roomName,
          summary: message.roomName,
          groupKey: message.roomUid.node.toString(),
          body: createNotificationTextFromMessageBrief(message),
          largeIcon: finalFilePath,
          notificationLayout: NotificationLayout.Messaging,
          payload: {'uid': room.uid, 'id': room.lastMessage.id.toString()},
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'REPLY',
            label: 'Reply',
            autoDismissable: false,
            showInCompactView: true,
            buttonType: ActionButtonType.InputField,
          ),
          NotificationActionButton(
            key: 'READ',
            label: 'Mark as read',
            autoDismissable: true,
          ),
        ]);
  }

  @override
  cancel(int id, String roomId) async {
    try {
      AwesomeNotifications()
          .cancelNotificationsByGroupKey(roomId.asUid().node.toString());
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancelAll() async {
    try {
      AwesomeNotifications().cancelAll();
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
    var macNotificationSetting = new MacOSInitializationSettings();

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
    if (message.ignoreNotification) return;

    List<MacOSNotificationAttachment> attachments = [];

    var la = await _avatarRepo.getLastAvatar(message.roomUid, false);

    if (la != null) {
      var f = await _fileRepo.getFileIfExist(la.fileId, la.fileName,
          thumbnailSize: ThumbnailSize.medium);

      if (f != null && f.path.isNotEmpty) {
        attachments.add(MacOSNotificationAttachment(f.path));
      }
    }

    var macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(attachments: attachments, badgeNumber: 0);
    _flutterLocalNotificationsPlugin.show(message.roomUid.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: macOSPlatformChannelSpecifics,
        payload: message.roomUid.asString());
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

String createNotificationTextFromMessageBrief(MessageBrief mb) {
  var text = "";
  if (!(mb.roomUid.isBot() || mb.roomUid.isUser()) && mb.senderIsAUserOrBot) {
    text += "${mb.sender.trim()}: ";
  }
  if (mb.typeDetails.isNotEmpty) {
    text += mb.typeDetails;
  }
  if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty) {
    text += ", ";
  }
  if (mb.text.isNotEmpty) {
    text += mb.text;
  }

  return text;
}
