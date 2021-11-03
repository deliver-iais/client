import 'dart:convert';

import 'package:deliver/box/dao/mute_dao.dart';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/main.dart';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/core_services.dart';


import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as M;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'notification_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class FireBaseServices {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _firebaseServices = GetIt.I.get<FirebaseServiceClient>();

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
    if (!await _sharedDao.getBoolean(SHARED_DAO_FIREBASE_SETTING_IS_SET)) {
      try {
        await _firebaseServices
            .registration(RegistrationReq()..tokenId = fireBaseToken);
        _sharedDao.putBoolean(SHARED_DAO_FIREBASE_SETTING_IS_SET, true);
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  _setFirebaseSetting() async {
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
  try {
    await setupDI();
  } catch (e) {
    Logger().e(e);
  }

  var _notificationServices = GetIt.I.get<NotificationServices>();
  var _authRepo = GetIt.I.get<AuthRepo>();
  var _uxService = GetIt.I.get<UxService>();
  var _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  var _muteDao = GetIt.I.get<MuteDao>();

  if (message.data.containsKey('body')) {
    M.Message msg = _decodeMessage(message.data["body"]);
    String roomName = message.data['title'];
    Uid roomUid = getRoomUid(_authRepo, msg);

    try {
      if (_uxService.isAllNotificationDisabled ||
          await _muteDao.isMuted(roomUid.asString()) ||
          !showNotifyForThisMessage(msg, _authRepo)) {
        return;
      }
    } catch (e) {}

    if (msg.from.category == Categories.SYSTEM) {
      roomName = APPLICATION_NAME;
    } else if (msg.from.category == Categories.BOT) {
      roomName = msg.from.node;
    } else if (msg.to.category == Categories.USER) {
      var uidName = await _uidIdNameDao.getByUid(msg.from.asString());
      if (uidName != null)
        roomName = uidName.name != null && uidName.name.isNotEmpty
            ? uidName.name
            : uidName.id != null && uidName.id.isNotEmpty
                ? uidName.id
                : msg.from.isGroup()
                    ? "Group"
                    : msg.from.isChannel()
                        ? "Channel"
                        : "UnKnown";
    }

    _notificationServices.showNotification(msg, roomName: roomName);
  }
}
