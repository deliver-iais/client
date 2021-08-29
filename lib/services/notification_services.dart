import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver_flutter/services/audio_service.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:desktoasts/desktoasts.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

abstract class Notifier {
  notify(MessageBrief message);

  cancel(int id);

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
    _notifier.cancel(roomUid.hashCode);
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
  cancel(int id) {}

  @override
  cancelAll() {}
}

class IOSNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id) {}

  @override
  cancelAll() {}
}

class WindowsNotifier implements Notifier {
  ToastService _windowsNotificationServices = new ToastService(
    appName: APPLICATION_NAME,
    companyName: "deliver.co.ir",
    productName: "deliver",
  );

  @override
  notify(MessageBrief message) async {
    var _avatarRepo = GetIt.I.get<AvatarRepo>();
    var fileRepo = GetIt.I.get<FileRepo>();
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

        //_windowsNotificationServices.dispose();
        //     toast.dispose();
      } else {
        Toast toast = new Toast(
          type: ToastType.text01,
          title: message.roomName,
          subtitle: createNotificationTextFromMessageBrief(message),
        );
        _windowsNotificationServices.show(toast);

        // _windowsNotificationServices.dispose();
        // toast.dispose();
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  cancel(int id) {}

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
  cancel(int id) async {
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
  final channel = const AndroidNotificationChannel(
      'notifications', // id
      'Notifications', // title
      'All notifications of application.', // description
      importance: Importance.high,
      groupId: "all_group");

  AndroidNotifier() {
    _flutterLocalNotificationsPlugin.createNotificationChannel(channel);

    var notificationSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
    AndroidBitmap largeIcon;

    var la = await _avatarRepo.getLastAvatar(message.roomUid, false);

    if (la != null) {
      var f = await _fileRepo.getFileIfExist(la.fileId, la.fileName,
          thumbnailSize: ThumbnailSize.medium);

      if (f != null && f.path.isNotEmpty) {
        largeIcon = FilePathAndroidBitmap(f.path);
      }
    }

    var platformChannelSpecifics = AndroidNotificationDetails(
        channel.id, channel.name, channel.description,
        groupKey: channel.groupId,
        largeIcon: largeIcon,
        setAsGroupSummary: false);

    _flutterLocalNotificationsPlugin.show(message.roomUid.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: platformChannelSpecifics,
        payload: message.roomUid.asString());
  }

  @override
  cancel(int id) async {
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
  cancel(int id) async {
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
