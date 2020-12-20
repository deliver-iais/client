import 'dart:convert';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
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

class FireBaseServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var _notificationServices = GetIt.I.get<NotificationServices>();
  var _accountRepo = GetIt.I.get<AccountRepo>();

  var fireBaseServices = FirebaseServiceClient(FirebaseServicesClientChannel);

  sendFireBaseToken(BuildContext context) async {
    _firebaseMessaging.requestNotificationPermissions();
    var fireBaseToken = await _firebaseMessaging.getToken();
    _sendFireBaseToken(fireBaseToken);
    print("@@@@@@@@" + fireBaseToken);
    _setFirebaseSetting(context);
  }

  _sendFireBaseToken(String fireBaseToken) async {
    await fireBaseServices.registration(
        RegistrationReq()..tokenId = fireBaseToken,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
  }

  _setFirebaseSetting(BuildContext context) {
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
  return Message.fromBuffer(dataTitle64);
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
