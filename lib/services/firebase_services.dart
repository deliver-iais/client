import 'dart:convert';

import 'package:deliver_flutter/box/dao/mute_dao.dart';

import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/main.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as M;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import 'notification_services.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class FireBaseServices {
  final _logger = Logger();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _firebaseServices =
      FirebaseServiceClient(FirebaseServicesClientChannel);
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  FirebaseMessaging _firebaseMessaging;

  sendFireBaseToken() async {
    if (!isDesktop()) {
      _firebaseMessaging = FirebaseMessaging.instance;
      _firebaseMessaging.requestPermission();
      await _setFirebaseSetting();
      _sendFireBaseToken(await _firebaseMessaging.getToken());
    }
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
        _logger.e(e);
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
      _logger.e(e);
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

  try {
    await setupDI();
  } catch (e) {
    Logger().e(e);
  }
  var _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  var _muteDao = GetIt.I.get<MuteDao>();

  // TODO needs to be refactored!!!
  var accountRepo = AccountRepo();
  // var roomRepo = RoomRepo();

  if (message.data.containsKey('body')) {
    M.Message msg = _decodeMessage(message.data["body"]);
    String roomName = message.data['title'];
    Uid roomUid = getRoomId(accountRepo, msg);

    // CoreServices.saveMessage(accountRepo, messageDao, roomDao, msg, roomUid);
    //  if (msg.from.category == Categories.USER)
    //      updateLastActivityTime(
    //          lastActivityDao, getRoomId(accountRepo, msg), msg.time.toInt());
    try {
      if ((await accountRepo.notification).contains("false") ||
          await _muteDao.isMuted(roomUid.asString()) ||
          accountRepo.isCurrentUser(msg.from.asString())) {
        return;
      }
    } catch (e) {}

    if (msg.to.category == Categories.USER) {
      var uidName = await _uidIdNameDao.getByUid(msg.from.asString());
      if (uidName != null) roomName = uidName.name ?? uidName.id ?? "unknown";
    } else if (msg.from.category == Categories.SYSTEM) {
      roomName = APPLICATION_NAME;
    } else if (msg.from.category == Categories.BOT) {
      roomName = msg.from.node;
    }

    await Hive.close();
    _notificationServices.showNotification(
        msg, getRoomId(accountRepo, msg).asString(), roomName);
  }
}
