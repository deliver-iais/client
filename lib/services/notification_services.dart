import 'dart:convert';

import 'package:deliver_flutter/db/database.dart' as db;
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

class NotificationServices {
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  NotificationDetails _notificationDetails;
  var _routinServices = GetIt.I.get<RoutingService>();
  String _currentRoomId;

  Map<String, String> _notificationMessage = Map();

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
      db.Message message, String roomName, String roomUid) async {
    try {
      cancelNotification(message.id - 1);
      switch (message.type) {
        case MessageType.TEXT:
          showTextNotification(
              message.id, roomUid, roomName, jsonDecode(message.json)['1']);
          break;
        case MessageType.FILE:
          showTextNotification(
              message.id, roomUid, roomName, "File");
          break;
        case MessageType.STICKER:
          // TODO: Handle this case.
          break;
        case MessageType.LOCATION:
          // TODO: Handle this case.
          break;
        case MessageType.LIVE_LOCATION:
          // TODO: Handle this case.
          break;
        case MessageType.POLL:
          // TODO: Handle this case.
          break;
        case MessageType.FORM:
          // TODO: Handle this case.
          break;
        case MessageType.PERSISTENT_EVENT:
          // TODO: Handle this case.
          break;
        case MessageType.NOT_SET:
          // TODO: Handle this case.
          break;
      }
    } catch (e) {}
  }

  void reset(String roomId) {
    _currentRoomId = roomId;
    _notificationMessage[roomId] = " ";
  }
}
