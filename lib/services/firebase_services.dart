import 'dart:convert';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

import 'notification_services.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

String Firabase_Setting_Is_Set = "firabase_setting_is_set";

class FireBaseServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var _notificationServices = GetIt.I.get<NotificationServices>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var fireBaseServices = FirebaseServiceClient(FirebaseServicesClientChannel);
  SharedPreferencesDao _prefs = GetIt.I.get<SharedPreferencesDao>();

  sendFireBaseToken() async {
    _firebaseMessaging.requestNotificationPermissions();
    var fireBaseToken = await _firebaseMessaging.getToken();
    _sendFireBaseToken(fireBaseToken);
    _setFirebaseSetting();
  }

  _sendFireBaseToken(String fireBaseToken) async {
    String firabase_setting = await _prefs.get(Firabase_Setting_Is_Set);
    if (true) {
      print("%%%%%%%%%" + fireBaseToken);
      try {
        var res = await fireBaseServices.registration(
            RegistrationReq()..tokenId = fireBaseToken,
            options: CallOptions(metadata: {
              'accessToken': await _accountRepo.getAccessToken()
            }));
        _prefs.set(Firabase_Setting_Is_Set, "true");
      } catch (e) {
        print(e.toString());
      }
    }
  }

  _setFirebaseSetting() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        Message mes = _decodeMessage(message["notification"]["body"]);
        print("new message");
        print("#######################" + message.toString());
        if (message.containsKey("notification")) {
          bool isCurrentUser =
              mes.from.node.contains(_accountRepo.currentUserUid.node);
          var roomUid = isCurrentUser
              ? mes.to
              : (mes.to.category == Categories.USER ? mes.from : mes.to);
          _notificationServices.showNotification(mes, roomUid.asString());
        }
        if (message.containsKey("data")) {
          // todo
        }
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // todo
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //todo
      },
    );
  }
}

Message _decodeMessage(String notificationBody) {
  final dataTitle64 = base64.decode(notificationBody);
  Message m = Message.fromBuffer(dataTitle64);
  return m;
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
