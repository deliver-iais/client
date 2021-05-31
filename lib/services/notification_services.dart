import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  NotificationDetails _notificationDetails;

  Map<String, List<int>> _notificationMessage = Map();

  NotificationServices() {
    if (!isDesktop()) Firebase.initializeApp();
    var androidNotificationSetting =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosNotificationSetting = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        androidNotificationSetting, iosNotificationSetting);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (room) {
      if (room != null && room.isNotEmpty) {}
      return;
    });
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  cancelNotification(notificationId) {
    try {
      flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      print(e.toString());
    }
  }

  cancelAllNotification() {
    try{
      flutterLocalNotificationsPlugin.cancelAll();
    }catch(e){
      print(e.toString());
    }

  }

  showTextNotification(int notificationId, String roomId, String roomName,
      String messageBody) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      roomName,
      messageBody,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
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
    _notificationDetails =
        NotificationDetails(androidNotificationDetails, iOSNotificationDetails);

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
        case pro.Message_Type.persistEvent:
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

          break;
      }
    } catch (e) {}
  }

  void reset(String roomId) {
    _notificationMessage[roomId]?.forEach((element) {
      cancelNotification(element);
    });
  }

  void playSoundNotification() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/ack.mp3"),
    );
  }
}
