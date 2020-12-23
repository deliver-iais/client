import 'dart:convert';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/database.dart' as db;
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

import 'notification_services.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

String Firabase_Setting_Is_Set = "firabase_setting_is_set";

class FireBaseServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var fireBaseServices = FirebaseServiceClient(FirebaseServicesClientChannel);
  SharedPreferencesDao _prefs = GetIt.I.get<SharedPreferencesDao>();

  sendFireBaseToken() async {
    _firebaseMessaging.requestNotificationPermissions();
    var fireBaseToken = await _firebaseMessaging.getToken();
    await _setFirebaseSetting();
    _sendFireBaseToken(fireBaseToken);
  }

  _sendFireBaseToken(String fireBaseToken) async {
    String firabase_setting = await _prefs.get(Firabase_Setting_Is_Set);
    if (firabase_setting == null) {

      try {
        await fireBaseServices.registration(
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
    try {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (message.containsKey("notification")) {
            // nothing
          }
          if (message.containsKey("data")) {
            //nothing
          }
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          if (message.containsKey("notification")) {
            //nothing

          }
        },
        onResume: (Map<String, dynamic> message) async {
          if (message.containsKey("notification")) {
            // npthing
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }
}

Message _decodeMessage(String notificationBody) {
  final dataTitle64 = base64.decode(notificationBody);
  Message m = Message.fromBuffer(dataTitle64);
  return m;
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  var _notificationServices = NotificationServices();
  var database = db.Database();
  var contactDao = database.contactDao;
  var mucDao = database.mucDao;

  if (message.containsKey('data')) {
    Message mes = _decodeMessage(message["data"]["body"]);
    String roomName;
    if (mes.to.category != Categories.USER) {
      var muc = await mucDao.getMucByUid(mes.to.asString());
      if(muc !=  null){
        roomName = muc.name;
      }else{
        roomName = "Unknown";
      }

    } else {
      db.Contact contact =
          await contactDao.getContactByUid(mes.from.asString());
      if (contact != null) {
        roomName =
            contact.firstName != null ? contact.firstName : contact.username??"Unknown";
        if (contact.lastName != null) {
          roomName = "$roomName ${contact.lastName}";
        } else {
          roomName = "Unknown";
        }
      }
    }
    _notificationServices.showNotification(mes, mes.from.asString(), roomName);
  }
  if (message.containsKey('notification')) {
    //todo
  }
}
