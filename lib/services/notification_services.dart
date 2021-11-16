import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:flutter_incoming_call/flutter_incoming_call.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as RTCVideoRenderer;
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
    if (message.whichType() == Message_Type.callEvent) {
      if (message.callEvent.newStatus == CallEvent_CallStatus.CREATED) {
        final mb =
            (await extractMessageBrief(_i18n, _roomRepo, _authRepo, message))
                .copyWith(roomName: roomName);
        if (mb.ignoreNotification) return;

        // TODO change place of synthesizer if we want more styled texts in android
        _notifier.notify(synthesize(mb));
      }
    } else {
      final mb =
          (await extractMessageBrief(_i18n, _roomRepo, _authRepo, message))
              .copyWith(roomName: roomName);
      if (mb.ignoreNotification) return;

      // TODO change place of synthesizer if we want more styled texts in android
      _notifier.notify(synthesize(mb));
    }
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
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notifications', // id
      'Notifications', // title
      description: 'All notifications of application.', // description
      importance: Importance.high,
      groupId: "all_group");

  AndroidNotifier() {
    FlutterIncomingCall.onEvent.listen((event) async {
      if (event is CallEvent) {
        if (event.action == CallAction.decline) {
          final callRepo = GetIt.I.get<CallRepo>();
          callRepo.declineCall();
          _routingService.pop();
        } else if (event.action == CallAction.accept) {
          _routingService.openInComingCallPage(event.uuid.asUid(),true);
        }
      }
    });
  }

  @override
  notify(MessageBrief message) async {
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
    if (message.type == MessageType.CALL) {
      FlutterIncomingCall.displayIncomingCall(
          room.uid,
          message.roomName,
          "data:image/jpeg;base64,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",
          'INCOMING CALL',
          HandleType.generic,
          true);
    } else {
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
            customSound: 'resource://raw/${selectedNotificationSound}',
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
