import 'dart:async';

import 'package:deliver/main.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundService {
  final _telephony = Telephony.instance;

  Future<void> startBackgroundService() async {
    await Workmanager().initialize(
      backgroundHandler, // The top level function, aka callbackDispatcher
    );

    await Workmanager().registerPeriodicTask(
      "update",
      "update",
      tag: "update",
      initialDelay: const Duration(
        minutes: 10,
      ),
      frequency: const Duration(hours: 1),
    );
    _setBackgroundService();
  }

  Future<void> enableListenOnSmsAnCall() async {
    final callGranted = await _telephony.requestPhonePermissions ?? false;
    final smsGranted = await _telephony.requestSmsPermissions ?? false;
    _setBackgroundService(listenOnSms: smsGranted, listenOnCall: callGranted);
  }

  void _setBackgroundService({
    bool listenOnCall = false,
    bool listenOnSms = false,
  }) {
    try {
      _telephony.connectionStream.listen((_) {});
      _telephony.listenOnAndroidReceiver(
        listenOnCall: listenOnCall,
        listenOnSms: listenOnSms,
        onNewMessage: (_) {},
        onBackgroundMessage: backgroundMessageHandler,
      );
    } catch (_) {}
  }
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {

  await update(updateFirebaseToken:message.body =="CONNECTION");
}

@pragma('vm:entry-point')
void backgroundHandler() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "update":
        await update();
        break;
    }
    return Future.value(true);
  });
}

Future<void> update({bool updateFirebaseToken = false}) async {
  print("update in packground.......");
    try {
      try {
        // hive does not support multithreading
        await Hive.close();
        await setupDI();
      } catch (_) {
        GetIt.I.get<UxService>().reInitialize();
      }
      GetIt.I.get<AppLifecycleService>().updateAppStateToPause();
      await GetIt.I.get<MessageRepo>().updatingMessages();
      if(updateFirebaseToken){
         unawaited (GetIt.I.get<FireBaseServices>().updateFirebaseToken());
      }
    } catch (_) {}

}
