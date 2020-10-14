import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

import 'notification_services.dart';

class FireBaseServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var notificationServices = GetIt.I.get<NotificationServices>();
  var accountRepo = GetIt.I.get<AccountRepo>();

  static ClientChannel _clientChannel = ClientChannel(
      ServicesDiscoveryRepo().fireBaseServices.host,
      port: ServicesDiscoveryRepo().fireBaseServices.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var fireBaseServices = FirebaseServiceClient(_clientChannel);

  sendFireBaseToken(BuildContext context) async {
    _firebaseMessaging.requestNotificationPermissions();
    var fireBaseToken = await _firebaseMessaging.getToken();
    _sendFireBaseToken(fireBaseToken);
    _setFirebaseSetting(context);
  }

  _sendFireBaseToken(String fireBaseToken) async {
    var result = await fireBaseServices.registration(
        RegistrationReq()..tokenId = fireBaseToken,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));

    print("result" + result.toString());
  }

  _setFirebaseSetting(BuildContext context) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("new message");
        if (message.containsKey("notification")) {
          notificationServices.showTextNotification(
              1,
              message["notification"]["title"],
              message["notification"]["title"],
              message["notification"]["body"]);
        }
        if (message.containsKey("data")) {
          // todo
        }
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // todo
        print("new message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

        //todo
      },
    );
  }
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
