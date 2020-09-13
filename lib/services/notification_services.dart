import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  BuildContext _context;
  NotificationDetails _notificationDetails;

  Map<int, String> notificationMessage = Map();

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
      int id, String title, String body, String payload) async {
    await showDialog(
        context: _context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title:
                Container(height: 80, color: Colors.blue, child: Text(title)),
            content:
                Text(body, style: TextStyle(color: Colors.black, fontSize: 18)),
            actions: <Widget>[
              GestureDetector(
                child: Text(
                  "Go",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                onTap: () {
                  gotoRoomPage("roomId");
                },
              )
            ],
          );
        });
  }

  gotoRoomPage(String roomId) {
    if (_context == null) {
      return;
    }
    ExtendedNavigator.of(_context).push(
      Routes.roomPage,
      arguments: RoomPageArguments(
        roomId: roomId,
      ),
    );
  }

  cancelNotification(int notificationId) {
    flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  cancelAllNotification(int notificationId) {
    notificationMessage[notificationId] = "";
    flutterLocalNotificationsPlugin.cancelAll();
  }

  showTextNotification(int notificationId, String roomId, BuildContext context,
      String roomName, String messageBody) async {
    _context = context;
    if (notificationMessage[notificationId] == null) {
      notificationMessage[notificationId] = "";
    }
    print(notificationMessage[notificationId]);
    notificationMessage[notificationId] =
        notificationMessage[notificationId] + "\n" + messageBody;
    var bigTextStyleInformation =
        BigTextStyleInformation(notificationMessage[notificationId]);
    var androidNotificationDetails = new AndroidNotificationDetails(
        'channel_ID', 'cs', 'desc',
        styleInformation: bigTextStyleInformation);
    var iOSNotificationDetails = IOSNotificationDetails();
    _notificationDetails =
        NotificationDetails(androidNotificationDetails, iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notificationId, roomName, "", _notificationDetails,
        payload: roomId);
  }

  showImageNotification(int notificationId, String roomId, BuildContext context,
      String roomName, String caption, String imagePath) async {
    _context = context;

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
}
