import 'dart:convert';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/seen.dart';

import 'package:deliver/main.dart';
import 'package:deliver/repository/accountRepo.dart';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/services/core_services.dart';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as pb_seen;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver/web_classes/js.dart'
    if (dart.library.html) 'package:js/js.dart' as js;

import 'package:logger/logger.dart';

import 'notification_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

@js.JS('decodeMessageForCallFromJs')
external set _decodeMessageForCallFromJs(void Function(dynamic s) f);

class FireBaseServices {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _firebaseServices = GetIt.I.get<FirebaseServiceClient>();
  final _queryServicesClient = GetIt.I.get<QueryServiceClient>();
  final List<String> _requestedRoom = [];

  Future<Map<String, String>> _decodeMessageForWebNotification(
      dynamic notification) async {
    Map<String, String> res = {};

    var mb = await _backgroundMessageHandler(notification);

    if (mb != null) {
      res['title'] = mb.roomName;
      res['body'] = createNotificationTextFromMessageBrief(mb);
    }

    return res;
  }

  late FirebaseMessaging _firebaseMessaging;

  sendFireBaseToken() async {
    if (!isDesktop || isWeb) {
      _firebaseMessaging = FirebaseMessaging.instance;
      await _firebaseMessaging.requestPermission();
      await _setFirebaseSetting();
      _sendFireBaseToken(await _firebaseMessaging.getToken());
    }
  }

  deleteToken() {
    _firebaseMessaging.deleteToken();
  }

  _sendFireBaseToken(String? fireBaseToken) async {
    try {
      if (!await _sharedDao.getBoolean(SHARED_DAO_FIREBASE_SETTING_IS_SET)) {
        try {
          await _firebaseServices
              .registration(RegistrationReq()..tokenId = fireBaseToken!);
          _sharedDao.putBoolean(SHARED_DAO_FIREBASE_SETTING_IS_SET, true);
        } catch (e) {
          _logger.e(e);
        }
      }
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  _setFirebaseSetting() async {
    if (isWeb) {
      _decodeMessageForCallFromJs =
          js.allowInterop(_decodeMessageForWebNotification);
    }
    //for web register in  firebase-messaging-sw.js in web folder;
    if (isAndroid) {
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

  void subscribeRoom(String roomUid) async {
    if (!_requestedRoom.contains(roomUid)) {
      try {
        await _queryServicesClient.sendGlitch(SendGlitchReq()
          ..offlineNotification =
              (GlitchOfOfflineNotification()..room = roomUid.asUid()));

        _requestedRoom.add(roomUid);
      } catch (e) {
        _logger.e(e);
      }
    }
  }
}

message_pb.Message _decodeMessage(String notificationBody) {
  final dataTitle64 = base64.decode(notificationBody);
  message_pb.Message m = message_pb.Message.fromBuffer(dataTitle64);
  return m;
}

Future<MessageBrief?> _backgroundMessageHandler(
    RemoteMessage remoteMessage) async {
  try {
    await setupDI();
  } catch (e) {
    Logger().e(e);
  }

  var _notificationServices = GetIt.I.get<NotificationServices>();
  var _authRepo = GetIt.I.get<AuthRepo>();
  var _messageDao = GetIt.I.get<MessageDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  var _seenDao = GetIt.I.get<SeenDao>();

  if (remoteMessage.data.containsKey('body')) {
    message_pb.Message msg = _decodeMessage(remoteMessage.data["body"]);

    String? roomName = remoteMessage.data['title'];
    if ((roomName ?? "").trim().isEmpty) {
      roomName = null;
    }

    Uid roomUid = getRoomUid(_authRepo, msg);

    try {
      var message = await saveMessage(msg, roomUid, _messageDao, _authRepo,
          _accountRepo, _roomDao, _seenDao, _mediaQueryRepo);
      if (!message.json.isEmptyMessage() &&
          await shouldNotifyForThisMessage(msg)) {
        return await _notificationServices.showNotification(msg,
            roomName: roomName);
      }
    } catch (_) {}
  } else if (remoteMessage.data.containsKey("seen")) {
    pb_seen.Seen seen =
        pb_seen.Seen.fromBuffer(base64.decode(remoteMessage.data["seen"]));
    if (_authRepo.isCurrentUser(seen.from.asString())) {
      _notificationServices.cancelRoomNotifications(seen.to.asString());
      _notificationServices.cancelNotificationById(0);
      _seenDao.saveMySeen(
        Seen(uid: seen.to.asString(), messageId: seen.id.toInt()),
      );
    }
  }

  return null;
}

Future<void> backgroundMessageHandler(RemoteMessage remoteMessage) async =>
    _backgroundMessageHandler(remoteMessage);
