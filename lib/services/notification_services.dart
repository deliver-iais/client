import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/audio_service.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/methods/message.dart';
import 'package:deliver_flutter/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/services.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

abstract class Notifier {
  notify(MessageBrief message);

  cancel(int id);

  cancelAll();
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

    _notifier.notify(mb);
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

class WindowsNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id) {}

  @override
  cancelAll() {}
}

class LinuxNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id) {}

  @override
  cancelAll() {}
}

class AndroidIOSNotifier implements Notifier {
  @override
  notify(MessageBrief message) {}

  @override
  cancel(int id) {}

  @override
  cancelAll() {}
}

class MacOSNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  MacOSNotifier() {
    var macNotificationSetting = new MacOSInitializationSettings();

    var initializationSettings =
        InitializationSettings(macOS: macNotificationSetting);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (room) {
      _logger.wtf(room);
      if (room != null && room.isNotEmpty) {
        _logger.wtf(room);
      }
      return;
    });
  }

  @override
  notify(MessageBrief message) {
    if (message.ignoreNotification) return;

    var macOSPlatformChannelSpecifics = MacOSNotificationDetails(attachments: [
      MacOSNotificationAttachment(
          'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png'),
    ], badgeNumber: 0);
    var platformChannelSpecifics =
        NotificationDetails(macOS: macOSPlatformChannelSpecifics);

    _flutterLocalNotificationsPlugin.show(
        message.roomUid.asString().hashCode,
        message.roomName,
        createNotificationTextFromMessageBrief(message),
        platformChannelSpecifics);
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
