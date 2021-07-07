import 'dart:convert';
import 'package:deliver_flutter/box/dao/last_activity_dao.dart';
import 'package:deliver_flutter/box/dao/message_dao.dart';
import 'package:deliver_flutter/box/dao/mute_dao.dart';
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
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
  GetIt.I.registerSingleton<LastActivityDao>(LastActivityDaoImpl());
  GetIt.I.registerSingleton<UidIdNameDao>(UidIdNameDaoImpl());
  GetIt.I.registerSingleton<MuteDao>(MuteDaoImpl());

  var lastActivityDao = GetIt.I.get<LastActivityDao>();

  // TODO needs to be refactored!!!
  var accountRepo = AccountRepo();
  var roomRepo = RoomRepo();
  var messageDao = MessageDaoImpl();
  var roomDao = RoomDaoImpl();

  if (message.data.containsKey('body')) {
    M.Message msg = _decodeMessage(message.data["body"]);
    String roomName = message.data['title'];
    Uid roomUid = getRoomId(accountRepo, msg);

    CoreServices.saveMessage(accountRepo, messageDao, roomDao, msg, roomUid);

    if (msg.from.category == Categories.USER)
      updateLastActivityTime(
          lastActivityDao, getRoomId(accountRepo, msg), msg.time.toInt());

    if ((await accountRepo.notification).contains("false") ||
        await roomRepo.isRoomMuted(roomUid.asString()) ||
        accountRepo.isCurrentUser(msg.from.asString())) {
      return;
    }

    if (msg.to.category == Categories.GROUP) {
      var to = await roomRepo.getName(msg.to);
      var from = await roomRepo.getName(msg.from);
      roomName = "$to${from != null && from.isNotEmpty ? " - " : ""}$from";
    } else if (msg.to.category == Categories.CHANNEL) {
      roomName = await roomRepo.getName(msg.to);
    } else {
      roomName = await roomRepo.getName(msg.from);
    }

    _notificationServices.showNotification(
        msg, getRoomId(accountRepo, msg).asString(), roomName);
  }
}
