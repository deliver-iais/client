import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
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
}

class NotificationServices {
  final _logger = GetIt.I.get<Logger>();
  final _audioService = GetIt.I.get<AudioService>();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Map<String, List<int>> _notificationMessage = Map();
  ToastService _windowsNotificationServices;

  NotificationServices() {
    if (isWindows()) {
      try {
        _windowsNotificationServices = ToastService(
          appName: APPLICATION_NAME,
          companyName: "we",
          productName: "deliver",
        );
      } catch (e) {
        _logger.e(e);
      }
    }
    if (isAndroid() || isIOS() || isMacOS()) {
      var androidNotificationSetting =
          new AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosNotificationSetting = new IOSInitializationSettings();
      var macNotificationSetting = new MacOSInitializationSettings();

      var initializationSettings = InitializationSettings(
          android: androidNotificationSetting,
          iOS: iosNotificationSetting,
          macOS: macNotificationSetting);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (room) {
        if (room != null && room.isNotEmpty) {}
        return;
      });
    }
  }

  cancelNotification(notificationId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      _logger.e(e);
    }
  }

  cancelAllNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }

  showTextNotification(int notificationId, String roomId, String roomName,
      String messageBody) async {
    if (isWindows()) {
      showWindowsNotify(roomId, roomName, messageBody);
    } else if (isLinux()) {
      try {
        var client = NotificationsClient();
        await client.notify('Deliver',
            body: "$roomName \n  $messageBody", appIcon: "mail-send");
        SystemSound.play(SystemSoundType.alert);
      } catch (e) {
        _logger.e(e);
      }
    } else {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'channel_id', 'channel_name', 'channel_description',
          importance: Importance.max, priority: Priority.high);
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var macOSPlatformChannelSpecifics = MacOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
          macOS: macOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        roomName,
        messageBody,
        platformChannelSpecifics,
        payload: 'Default_Sound',
      );
    }
  }

  void showWindowsNotify(
      String roomUid, String roomName, String messageBody) async {
    try {
      var _avatarRepo = GetIt.I.get<AvatarRepo>();
      var fileRepo = GetIt.I.get<FileRepo>();
      var lastAvatar = await _avatarRepo.getLastAvatar(roomUid.asUid(), false);
      if (lastAvatar != null) {
        var file = await fileRepo.getFile(
            lastAvatar.fileId, lastAvatar.fileName,
            thumbnailSize: ThumbnailSize.medium);
        Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: roomName,
            subtitle: messageBody,
            image: file);
        _windowsNotificationServices.show(toast);

        toast.dispose();
      } else {
        Toast toast = new Toast(
          type: ToastType.text04,
          title: roomName,
          subtitle: messageBody,
        );
        _windowsNotificationServices.show(toast);
        // _windowsNotificationServices.dispose();
        toast.dispose();
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  showImageNotification(int notificationId, String roomId, String roomName,
      String caption, String imagePath) async {
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      contentTitle: roomName,
      htmlFormatContentTitle: true,
      summaryText: caption,
      htmlFormatSummaryText: true,
    );

    var androidNotificationDetails = new AndroidNotificationDetails(
        'channel_ID', 'cs', 'desc',
        styleInformation: bigPictureStyleInformation);
    var iOSNotificationDetails = IOSNotificationDetails();
    var macOSNotificationDetails = MacOSNotificationDetails();
    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
        macOS: macOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notificationId, roomName, imagePath, notificationDetails,
        payload: roomId);
  }

  void showNotification(
      pro.Message message, String roomUid, String roomName) async {
    try {
      String text = "";

      switch (message.whichType()) {
        case pro.Message_Type.text:
          text = message.text.text;
          break;
        case pro.Message_Type.file:
          text = "File";
          break;
        case pro.Message_Type.sticker:
          text = "Sticker";
          break;
        case pro.Message_Type.liveLocation:
        case pro.Message_Type.location:
          text = "Location";
          break;
        case pro.Message_Type.poll:
          text = "Poll";
          break;
        case pro.Message_Type.buttons:
          text = "Buttons";
          break;
        case pro.Message_Type.form:
          text = "Form";
          break;
        case pro.Message_Type.shareUid:
          text = message.shareUid.name;
          break;
        case pro.Message_Type.formResult:
          text = "Form Result";
          break;
        case pro.Message_Type.sharePrivateDataRequest:
          text = "Access Question on Private Data";
          break;
        case pro.Message_Type.sharePrivateDataAcceptance:
          text = "Acceptance on Private Data";
          break;
        case pro.Message_Type.paymentTransaction:
          text = "Payment Transaction";
          break;
        case pro.Message_Type.persistEvent:
          switch (message.persistEvent.whichType()) {
            case PersistentEvent_Type.mucSpecificPersistentEvent:
              switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
                case MucSpecificPersistentEvent_Issue.ADD_USER:
                  text = " عضو اضافه شد.";
                  break;
                case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
                  text = "عکس پروفایل عوض شد";
                  break;
                case MucSpecificPersistentEvent_Issue.JOINED_USER:
                  text = "به گروه پیوست.";
                  break;
                case MucSpecificPersistentEvent_Issue.KICK_USER:
                  text = "مخاطب از گروه حذف شد.";
                  break;
                case MucSpecificPersistentEvent_Issue.LEAVE_USER:
                  text = "مخاطب  گروه  را ترک کرد.";
                  break;
                case MucSpecificPersistentEvent_Issue.MUC_CREATED:
                  text = " گروه  ساخته شد.";
                  break;
                case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
                  text = " نام تغییر پیدا کرد.";
                  break;
                case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
                  text = "پیام پین شد.";
                  break;
              }
              break;
            case PersistentEvent_Type.messageManipulationPersistentEvent:
              break;
            case PersistentEvent_Type.adminSpecificPersistentEvent:
              text = "به دلیور پیوست";
              break;
            case PersistentEvent_Type.notSet:
              break;
          }
          break;
        default:
          break;
      }

      if (text == null || text.isEmpty) return;

      if (_notificationMessage[roomUid] == null) {
        _notificationMessage[roomUid] = [];
      }
      _notificationMessage[roomUid].add(message.id.toInt());

      if (isLinux()) {
        playIncomingMsg();
      }

      showTextNotification(message.id.toInt(), roomUid, roomName, text);
    } catch (e) {}
  }

  void cancelAllNotifications(String roomId) {
    if (_notificationMessage[roomId] != null)
      _notificationMessage[roomId].forEach((element) async {
        await cancelNotification(element);
      });
  }

  void playSoundIn() async {}

  void playIncomingMsg() async {}

  void playSoundOut() {
    _audioService.playSoundOut();
  }
}

class WindowsNotifier implements Notifier {
  @override
  notify(MessageBrief message) {
  }
}

class LinuxNotifier implements Notifier {
  @override
  notify(MessageBrief message) {
  }
}

class AndroidIOSMacOSNotifier implements Notifier {
  @override
  notify(MessageBrief message) {
  }
}