import 'dart:convert';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/main.dart';
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
import 'package:logger/logger.dart';

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
      _sendFireBaseToken(await _firebaseMessaging.getToken());
    }
  }

  void deleteToken() {
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
    try {
      if (isWeb) {
        // For web register in  firebase-messaging-sw.js in web folder.
        // in here we just set decoder function interop.
        _decodeMessageForCallFromJs =
            js.allowInterop(_decodeMessageForWebNotification);
      } else if (isAndroid) {
        FirebaseMessaging.onBackgroundMessage(_backgroundRemoteMessageHandler);
        _firebaseMessaging.setForegroundNotificationPresentationOptions(
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
  final m = message_pb.Message.fromBuffer(dataTitle64);
  return m;
}

Future<void> _backgroundRemoteMessageHandler(
    RemoteMessage remoteMessage) async {
  if (remoteMessage.data.containsKey('body')) {
    try {
      await setupDI();

      final msg = _decodeMessage(remoteMessage.data["body"]);

      String? roomName = remoteMessage.data['title'];
      if ((roomName ?? "").trim().isEmpty) {
        roomName = null;
      }

      return await GetIt.I
          .get<DataStreamServices>()
          .handleIncomingMessage(msg, roomName: roomName);
    } catch (e) {
      Logger().e(e);
    }
  } else if (remoteMessage.data.containsKey("seen")) {
    try {
      await setupDI();

      final seen =
          pb_seen.Seen.fromBuffer(base64.decode(remoteMessage.data["seen"]));

      return await GetIt.I.get<DataStreamServices>().handleSeen(seen);
    } catch (e) {
      Logger().e(e);
    }
  }
}
