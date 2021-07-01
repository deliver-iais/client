import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  NotificationDetails _notificationDetails;

  Map<String, List<int>> _notificationMessage = Map();
  ToastService _windowsNotificationServices;

  NotificationServices() {
    if (!isDesktop()) Firebase.initializeApp();
    if (isWindows()) {
      _windowsNotificationServices = new ToastService(
        appName: 'Deliver',
        companyName: 'Pshk',
        productName: '1',
      );
    }
    var androidNotificationSetting =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosNotificationSetting = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
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

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  cancelNotification(notificationId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      debug(e.toString());
    }
  }

  cancelAllNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debug(e.toString());
    }
  }

  showTextNotification(int notificationId, String roomId, String roomName,
      String messageBody) async {
    if (isWindows()) {


      Toast toast = new Toast(
          type: ToastType.imageAndText04,
          title: roomName,
          subtitle: messageBody,
      );
      _windowsNotificationServices.show(toast);
      // _windowsNotificationServices.dispose();
     toast.dispose();
    } else if (isLinux()) {
      try {
        var client = NotificationsClient();
        await client.notify('Deliver',
            body: "$roomName \n  $messageBody", appIcon: "mail-send");
        SystemSound.play(SystemSoundType.alert);
      } catch (e) {
        print(e.toString());
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
    _notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notificationId, roomName, imagePath, _notificationDetails,
        payload: roomId);
  }

  void showNotification(
      pro.Message message, String roomUid, String roomName) async {
    try {
      if (_notificationMessage[roomUid] == null) {
        _notificationMessage[roomUid] = List();
      }
      _notificationMessage[roomUid].add(message.id.toInt());
      switch (message.whichType()) {
        case pro.Message_Type.text:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, message.text.text);
          break;
        case pro.Message_Type.file:
          showTextNotification(message.id.toInt(), roomUid, roomName, "File");
          break;
        case pro.Message_Type.sticker:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, "sticker");
          break;
        case pro.Message_Type.liveLocation:
        case pro.Message_Type.location:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, "Location");
          break;

        case pro.Message_Type.poll:
          showTextNotification(message.id.toInt(), roomUid, roomName, "poll");
          break;
        case pro.Message_Type.buttons:
        case pro.Message_Type.form:
          showTextNotification(message.id.toInt(), roomUid, roomName, "from");
          break;
        case pro.Message_Type.shareUid:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, message.shareUid.name);
          break;
        case pro.Message_Type.formResult:
          showTextNotification(message.id.toInt(), roomUid, roomName, "from");
          break;
        case pro.Message_Type.sharePrivateDataRequest:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, "Private");
          break;
        case pro.Message_Type.sharePrivateDataAcceptance:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, "Private");
          break;

        case pro.Message_Type.paymentTransaction:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, "Transaction");
          break;
        case pro.Message_Type.persistEvent:
          String s = "";
          switch (message.persistEvent.whichType()) {
            case PersistentEvent_Type.mucSpecificPersistentEvent:
              switch (message.persistEvent.mucSpecificPersistentEvent.issue) {
                case MucSpecificPersistentEvent_Issue.ADD_USER:
                  s = " عضو اضافه شد.";
                  break;

                case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
                  s = "عکس پروفایل عوض شد";
                  break;
                case MucSpecificPersistentEvent_Issue.JOINED_USER:
                  s = "به گروه پیوست.";
                  break;

                case MucSpecificPersistentEvent_Issue.KICK_USER:
                  s = "مخاطب از گروه حذف شد.";
                  break;
                case MucSpecificPersistentEvent_Issue.LEAVE_USER:
                  s = "مخاطب  گروه  را ترک کرد.";
                  break;
                case MucSpecificPersistentEvent_Issue.MUC_CREATED:
                  s = " گروه  ساخته شد.";
                  break;
                case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
                  s = " نام تغییر پیدا کرد.";
                  break;
                case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
                  s = "پیام پین شد.";
                  break;
              }
              break;
            case PersistentEvent_Type.messageManipulationPersistentEvent:
              //
              break;
            case PersistentEvent_Type.adminSpecificPersistentEvent:
              s = "به دلیور پیوست";

              break;
            case PersistentEvent_Type.notSet:
              // TODO: Handle this case.
              break;
          }
          showTextNotification(message.id.toInt(), roomUid, roomName, s);

          break;
      }
    } catch (e) {}
  }

  void reset(String roomId) {
    if (_notificationMessage[roomId] != null)
      _notificationMessage[roomId].forEach((element) async {
        await cancelNotification(element);
      });
  }

  void playSoundNotification() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/ack.mp3"),
    );
  }
}
