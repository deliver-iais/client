import 'dart:async';
import 'dart:convert';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/web_classes/js.dart'
    if (dart.library.html) 'package:js/js.dart' as js;
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as pb_seen;
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

@js.JS('decodeMessageForCallFromJs')
external set _decodeMessageForCallFromJs(Function f);

class FireBaseServices {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _services =
      GetIt.I.get<ServicesDiscoveryRepo>();

  final List<String> _requestedRoom = [];

  Future<Map<String, String>> _decodeMessageForWebNotification(
    notification,
  ) async {
    final res = <String, String>{};

    await _backgroundRemoteMessageHandler(notification);

    res['title'] = APPLICATION_NAME;
    res['body'] = "New message arrived";

    return res;
  }

  late FirebaseMessaging _firebaseMessaging;

  Future<void> sendFireBaseToken() async {
    if (!isDesktop || isWeb) {
      _firebaseMessaging = FirebaseMessaging.instance;
      await _firebaseMessaging.requestPermission();
      await _setFirebaseSetting();
      return _sendFirebaseToken(await _firebaseMessaging.getToken());
    }
  }

  void deleteToken() {
    _firebaseMessaging.deleteToken();
  }

  Future<void> _sendFirebaseToken(String? fireBaseToken) async {
    try {
      if (!await _sharedDao.getBoolean(SHARED_DAO_FIREBASE_SETTING_IS_SET)) {
        try {
          await _services.firebaseServiceClient
              .registration(RegistrationReq()..tokenId = fireBaseToken!);
          return _sharedDao.putBoolean(
            SHARED_DAO_FIREBASE_SETTING_IS_SET,
            true,
          );
        } catch (e) {
          _logger.e(e);
        }
      }
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  Future<void> _setFirebaseSetting() async {
    try {
      if (isWeb) {
        // For web register in  firebase-messaging-sw.js in web folder.
        // in here we just set decoder function interop.
        _decodeMessageForCallFromJs =
            js.allowInterop(_decodeMessageForWebNotification);
      } else if (isAndroid) {
        FirebaseMessaging.onBackgroundMessage(_backgroundRemoteMessageHandler);
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      // Other platform not supported for now
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendGlitchReportForFirebaseNotification(String roomUid) async {
    if (!_requestedRoom.contains(roomUid)) {
      try {
        await _services.queryServiceClient.sendGlitch(
          SendGlitchReq()
            ..offlineNotification =
                (GlitchOfOfflineNotification()..room = roomUid.asUid()),
        );

        _requestedRoom.add(roomUid);
      } catch (e) {
        _logger.e(e);
      }
    }
  }
}

message_pb.Message _decodeMessage(String notificationBody) {
  final dataTitle64 = base64.decode(notificationBody);
  final m = message_pb.Message.fromBuffer(dataTitle64);
  return m;
}

Future<void> _backgroundRemoteMessageHandler(
  RemoteMessage remoteMessage,
) async {
  if (remoteMessage.data.containsKey('body')) {
    try {
      // hive does not support multithreading
      await Hive.close();
      await setupDI();
    } catch (_) {}

    try {
      final msg = _decodeMessage(remoteMessage.data["body"]);

      String? roomName = remoteMessage.data['title'];
      if ((roomName ?? "").trim().isEmpty) {
        roomName = null;
      }

      await GetIt.I.get<DataStreamServices>().handleIncomingMessage(
            msg,
            roomName: roomName,
            isOnlineMessage: true,
            isFirebaseMessage: true,
          );

      return;
    } catch (e) {
      Logger().e(e);
    }
  } else if (remoteMessage.data.containsKey("seen")) {
    try {
      await setupDI();
    } catch (_) {}
    try {
      final seen =
          pb_seen.Seen.fromBuffer(base64.decode(remoteMessage.data["seen"]));

      return await GetIt.I.get<DataStreamServices>().handleSeen(seen);
    } catch (e) {
      Logger().e(e);
    }
  }
}
