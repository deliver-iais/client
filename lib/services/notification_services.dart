import 'dart:convert';

import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

class NotificationServices {
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  NotificationDetails _notificationDetails;
  var _routinServices = GetIt.I.get<RoutingService>();

  var _messageRepo = GetIt.I.get<MessageRepo>();

  Map<String, String> _notificationMessage = Map();
  Map<String,int> _notificationMap = Map();

  NotificationServices() {
    var androidNotificationSetting =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosNotificationSetting = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        androidNotificationSetting, iosNotificationSetting);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (room) {
      if (room != null && room.isNotEmpty) {
        gotoRoomPage(room);
      }
      return;
    });
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  gotoRoomPage(String roomId) {
    _routinServices.openRoom(roomId);
  }

  cancelNotification(notificationId) {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  cancelAllNotification(String roomId) {
    _notificationMessage[roomId] = "";
    flutterLocalNotificationsPlugin.cancelAll();
  }

  showTextNotification(int notificationId, String roomId, String roomName,
      String messageBody) async {
    try {
      if (_notificationMessage[roomId] == null) {
        _notificationMessage[roomId] = " ";
      }
      _notificationMessage[roomId] =
          _notificationMessage[roomId] + "\n" + messageBody;
      var bigTextStyleInformation =
          BigTextStyleInformation(_notificationMessage[roomId]);
      var androidNotificationDetails = new AndroidNotificationDetails(
          'channel_ID', 'cs', 'desc',
          styleInformation: bigTextStyleInformation);
      var iOSNotificationDetails = IOSNotificationDetails();
      _notificationDetails = NotificationDetails(
          androidNotificationDetails, iOSNotificationDetails);

      await flutterLocalNotificationsPlugin.show(
          notificationId, roomName, "", _notificationDetails,
          payload: roomId);
    } catch (e) {}
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
      pro.Message message, String roomName, String roomUid) async {
    if(_notificationMap[roomUid] != null && _notificationMap[roomUid]<= message.id.toInt()){
      return;
    }
    try {
      _notificationMap[roomUid] == message.id;
      cancelNotification(message.id - 1);
      switch (message.whichType()) {
        case pro.Message_Type.persistEvent:
        case pro.Message_Type.text:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, jsonDecode(message.text.text)['1']);
          break;
        case pro.Message_Type.file:
          showTextNotification(
              message.id.toInt(), roomUid, roomName, "File");
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

  void reset(String roomId) {
    _notificationMessage[roomId] = " ";
  }
}
