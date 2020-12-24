import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  NotificationDetails _notificationDetails;
  String _currentRoomUid;

  AudioPlayer audioPlayer = AudioPlayer();

  Map<String, String> _notificationMessage = Map();
  Map<String, int> _notificationMap = Map();

  NotificationServices() {
    Firebase.initializeApp();
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
    flutterLocalNotificationsPlugin.cancelAll();
  }

  cancelAllNotification(String roomId) {
    _notificationMessage[roomId] = "";
    flutterLocalNotificationsPlugin.cancelAll();
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
    if (_currentRoomUid != null && _currentRoomUid.contains(roomUid)) {
      _playNotificationSound();
    } else {
      try {
        _notificationMap[roomUid] == message.id;
        cancelNotification(message.id - 1);
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
            // TODO: Handle this case.
            break;
          case pro.Message_Type.location:
            // TODO: Handle this case.
            break;
          case pro.Message_Type.liveLocation:
            // TODO: Handle this case.
            break;
          case pro.Message_Type.poll:
            // TODO: Handle this case.
            break;
          case pro.Message_Type.form:
            // TODO: Handle this case.
            break;
        }
      } catch (e) {}
    }
  }

  void reset(String roomId) {
    _notificationMessage[roomId] = "\t";
    _currentRoomUid = roomId;
  }

  void palyAckMessageNotification(String roomUid) {
    if (_currentRoomUid != null && _currentRoomUid.contains(roomUid))
      audioPlayer.play('');
  }

  void _playNotificationSound() {
    audioPlayer.play("");
  }
}
