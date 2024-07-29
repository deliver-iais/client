import 'dart:async';
import 'dart:convert';

import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/web_classes/js.dart'
    if (dart.library.html) 'package:js/js.dart' as js;
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
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
  final _services = GetIt.I.get<ServicesDiscoveryRepo>();
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
    if (hasFirebaseCapability) {
      _firebaseMessaging = FirebaseMessaging.instance;
      await _firebaseMessaging.requestPermission();
      await _setFirebaseSetting();
      if (!settings.firebaseSettingIsSet.value) {
        try {
          String? token;
          try {
            token = await _firebaseMessaging.getToken();
          } catch (e) {
            _logger.e(e);
          }

          token ??= settings.firebaseToken.value;
          if (token.isNotEmpty) {
            _saveFirebaseToken(token);
            unawaited(_sendFirebaseToken(token));
          }
        } catch (e) {
          _logger.e(e);
        }
      }
    }
  }

  void _saveFirebaseToken(String token) {
    settings.firebaseToken.set(token);
  }

  Future<void> updateFirebaseToken() async {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;
      await _firebaseMessaging.requestPermission();
      final firebaseToken = await _firebaseMessaging.getToken();
      if (firebaseToken != null) {
        _saveFirebaseToken(firebaseToken);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void deleteToken() {
    try {
      if (hasFirebaseCapability) {
        _firebaseMessaging.deleteToken();
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _sendFirebaseToken(String fireBaseToken) async {
    try {
      try {
        await _services.firebaseServiceClient
            .registration(RegistrationReq()..tokenId = fireBaseToken);
        settings.firebaseSettingIsSet.set(true);
      } catch (e) {
        _logger.e(e);
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
      } else if (isAndroidNative) {
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

@pragma('vm:entry-point')
Future<void> _backgroundRemoteMessageHandler(
  RemoteMessage remoteMessage,
) async {
  try {
    // hive does not support multithreading
    try {
      await Hive.close();
    } catch (e) {}

    await setupDI();
  } catch (_) {
    GetIt.I.get<Settings>().reInitialize();
  }
  if (remoteMessage.data.containsKey('body')) {
    try {
      final msg = _decodeMessage(remoteMessage.data["body"]);

      String? roomName = remoteMessage.data['title'];
      if ((roomName ?? "").trim().isEmpty) {
        roomName = null;
      }

      final roomUid = getRoomUid(GetIt.I.get<AuthRepo>(), msg);

      //check is message repeated or not
      final lastRoomMessageId =
          (await GetIt.I.get<RoomDao>().getRoom(roomUid))?.lastMessageId ?? 0;

      if (lastRoomMessageId < msg.id.toInt()) {
        await GetIt.I.get<DataStreamServices>().handleIncomingMessage(
              msg,
              roomName: roomName,
              isOnlineMessage: true,
              isFirebaseMessage: true,
            );
      }

      return;
    } catch (e) {
      Logger().e(e);
    }
  } else if (remoteMessage.data.containsKey("seen")) {
    try {
      final seen =
          pb_seen.Seen.fromBuffer(base64.decode(remoteMessage.data["seen"]));

      return await GetIt.I.get<DataStreamServices>().handleSeen(seen);
    } catch (e) {
      Logger().e(e);
    }
  } else if (remoteMessage.data.containsKey("callAction")) {
    try {
      final callEventV2 = call_pb.CallEventV2.fromBuffer(
        base64.decode(remoteMessage.data["callAction"]),
      );
      return await GetIt.I
          .get<DataStreamServices>()
          .handleCallEvent(callEventV2);
    } catch (e) {
      Logger().e(e);
    }
  }
}
