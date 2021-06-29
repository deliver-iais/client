import 'dart:convert';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/db/database.dart' as db;
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/utils/log.dart';
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

class FireBaseServices {
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _sharedDao = GetIt.I.get<SharedDao>();
  var _firebaseServices = FirebaseServiceClient(FirebaseServicesClientChannel);
  var _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FirebaseMessaging _firebaseMessaging;

  sendFireBaseToken() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.requestPermission();
    await _setFirebaseSetting();
    _sendFireBaseToken(await _firebaseMessaging.getToken());
  }

  deleteToken() {
    _firebaseMessaging.deleteToken();
  }

  _sendFireBaseToken(String fireBaseToken) async {
    String firebaseSetting =
        await _sharedDao.get(SHARED_DAO_FIREBASE_SETTING_IS_SET);
    if (firebaseSetting == null) {
      try {
        await _firebaseServices.registration(
            RegistrationReq()..tokenId = fireBaseToken,
            options: CallOptions(metadata: {
              'access_token': await _accountRepo.getAccessToken()
            }));
        _sharedDao.put(SHARED_DAO_FIREBASE_SETTING_IS_SET, "true");
      } catch (e) {
        debug(e.toString());
      }
    }
  }

  _setFirebaseSetting() async {
    await _flutterLocalNotificationsPlugin
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
      debug(e);
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

  GetIt.I.registerSingleton<SharedDao>(SharedDaoImpl());

  var database = db.Database();
  var contactDao = database.contactDao;
  var roomDao = database.roomDao;
  var messageDao = database.messageDao;
  var userInfoDao = database.userInfoDao;
  var accountRepo = AccountRepo();

  if (message.data.containsKey('body')) {
    M.Message msg = _decodeMessage(message.data["body"]);
    String roomName = message.data['title'];
    Uid roomUid = getRoomId(accountRepo, msg);
    var currentUserUid = await accountRepo.getCurrentUserUid();
    db.Room room = await roomDao.getByRoomIdFuture(roomUid.asString());
    if (room != null &&
        room.isBlock &&
        msg.from.isSameEntity(currentUserUid.asString())) {
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
        var res = await userInfoDao.getUserInfo(msg.from.asString());
        if (res != null) roomName = res.username;
      }
    } else if (msg.from.category == Categories.SYSTEM) {
      roomName = "Deliver";
    } else if (msg.from.category == Categories.BOT) {
      if (roomName.isEmpty) roomName = "Bot";
    }

    if (msg.from.category == Categories.USER)
      updateLastActivityTime(userInfoDao, getRoomId(accountRepo, msg),
          DateTime.fromMillisecondsSinceEpoch(msg.time.toInt()));
    if ((await accountRepo.notification).contains("true") &&
        (room != null && !room.mute))
      _notificationServices.showNotification(
          msg, getRoomId(accountRepo, msg).asString(), roomName);
  }
}
