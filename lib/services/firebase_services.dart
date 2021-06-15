import 'dart:convert';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/database.dart' as db;
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as M;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

import 'notification_services.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

String Firabase_Setting_Is_Set = "firabase_setting_is_set";

class FireBaseServices {
  FirebaseMessaging _firebaseMessaging;

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var fireBaseServices = FirebaseServiceClient(FirebaseServicesClientChannel);
  SharedPreferencesDao _prefs = GetIt.I.get<SharedPreferencesDao>();

  sendFireBaseToken() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.requestPermission();
    var fireBaseToken = await _firebaseMessaging.getToken();
    await _setFirebaseSetting();
    _sendFireBaseToken(fireBaseToken);
  }

  deleteFirabseInstaceIs() {
    FireBaseServices().deleteFirabseInstaceIs();
  }

  _sendFireBaseToken(String fireBaseToken) async {
    String firabase_setting = await _prefs.get(Firabase_Setting_Is_Set);
    if (firabase_setting == null) {
      try {
        await fireBaseServices.registration(
            RegistrationReq()..tokenId = fireBaseToken,
            options: CallOptions(metadata: {
              'access_token': await _accountRepo.getAccessToken()
            }));
        _prefs.set(Firabase_Setting_Is_Set, "true");
      } catch (e) {
        print(e.toString());
      }
    }
  }

  _setFirebaseSetting() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    try {
      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
      _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print(e);
    }
  }
}

M.Message _decodeMessage(String notificationBody) {
  final dataTitle64 = base64.decode(notificationBody);
  M.Message m = M.Message.fromBuffer(dataTitle64);
  return m;
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  var _notificationServices = NotificationServices();

  var database = db.Database();
  var contactDao = database.contactDao;
  var roomDao = database.roomDao;
  var messageDao = database.messageDao;
  var sharedPreferencesDao = database.sharedPreferencesDao;
  var accountRepo = AccountRepo(sharedPrefs: sharedPreferencesDao);
  var _userInfoDao = database.userInfoDao;

  if (message.data.containsKey('body')) {
    M.Message msg = _decodeMessage(message.data["body"]);
    String roomName = message.data['title'];
    Uid roomUid = getRoomId(accountRepo, msg);
    var currentUseruid = await accountRepo.getCurrentUserUid();
    db.Room room = await roomDao.getByRoomIdFuture(roomUid.asString());
    if (room != null &&
        room.isBlock &&
        msg.from.isSameEntity(currentUseruid.asString())) {
      return;
    }
    CoreServices.saveMessage(accountRepo, messageDao, roomDao, msg, roomUid);
    if (msg.to.category == Categories.USER &&
        msg.from.category != Categories.SYSTEM &&
        msg.from.category != Categories.BOT) {
      db.Contact contact =
          await contactDao.getContactByUid(msg.from.asString());
      if (contact != null) {
        roomName =
            contact.firstName != null ? contact.firstName : contact.username;
        if (contact.lastName != null) {
          roomName = "$roomName ${contact.lastName}";
        }
      } else {
        var res = await _userInfoDao.getUserInfo(msg.from.asString());
        if (res != null) roomName = res.username;
      }
    } else if (msg.from.category == Categories.SYSTEM) {
      roomName = "Deliver";
    } else if (msg.from.category == Categories.BOT) {
      if (roomName.isEmpty) roomName = "Bot";
    }

    if (msg.from.category == Categories.USER)
      updateLastActivityTime(_userInfoDao, getRoomId(accountRepo, msg),
          DateTime.fromMillisecondsSinceEpoch(msg.time.toInt()));
    if ((await accountRepo.notification).contains("true") &&
        (room != null && !room.mute))
      _notificationServices.showNotification(
          msg, getRoomId(accountRepo, msg).asString(), roomName);
  }
}
