import 'dart:convert';

import 'package:deliver/box/dao/mute_dao.dart';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/main.dart';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
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

import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:js/js.dart';
import 'package:logger/logger.dart';

import 'notification_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

@JS('decodeMessageForCallFromJs')
external set _decodeMessageForCallFromJs(void Function(dynamic s) f);

class FireBaseServices {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _firebaseServices = GetIt.I.get<FirebaseServiceClient>();

  Future<Map<String, String>> _decodeMessageForWebNotification(
      dynamic notification) async {
    Map<String, String> res = Map();
    try {
      await setupDI();
    } catch (e) {
      Logger().e(e);
    }
    var _i18n = GetIt.I.get<I18N>();
    var _authRepo = GetIt.I.get<AuthRepo>();
    var _uxService = GetIt.I.get<UxService>();
    var _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
    var _muteDao = GetIt.I.get<MuteDao>();
    var _roomRepo = GetIt.I.get<RoomRepo>();
    final dataTitle64 = base64.decode(notification);
    M.Message message = M.Message.fromBuffer(dataTitle64);
    var messageBrief =
        await extractMessageBrief(_i18n, _roomRepo, _authRepo, message);
    M.Message msg = _decodeMessage(notification.data["body"]);
    String roomName = notification.data['title'];
    Uid roomUid = getRoomUid(_authRepo, msg);

    try {
      if (_uxService.isAllNotificationDisabled ||
          await _muteDao.isMuted(roomUid.asString()) ||
          !showNotifyForThisMessage(msg, _authRepo)) {
        return null;
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
    res[roomName] = messageBrief.text;
    return res;
  }

  FirebaseMessaging _firebaseMessaging;

  sendFireBaseToken() async {
    if (!isDesktop() || kIsWeb) {
      try{
        _firebaseMessaging = FirebaseMessaging.instance;
        await _firebaseMessaging.requestPermission();
        var res = await _firebaseMessaging.getToken();
        _logger.d("TOKEN:" + res);
        await _setFirebaseSetting();
        _sendFireBaseToken(await _firebaseMessaging.getToken());
      }catch(e){
        print("%%%%%%%%%%$e");
      }

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
    if (kIsWeb) {
      _decodeMessageForCallFromJs =
          allowInterop(_decodeMessageForWebNotification);
    }

    //for web register in  firebase-messaging-sw.js in web folder;
    if (isAndroid()) {
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
}

M.Message _decodeMessage(String notificationBody) {
  final dataTitle64 = base64.decode(notificationBody);
  M.Message m = M.Message.fromBuffer(dataTitle64);
  return m;
}

Future<void> backgroundMessageHandler(dynamic message) async {
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
