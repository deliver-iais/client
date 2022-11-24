import 'package:deliver/main.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

final _requestLock = Lock();

class BackgroundService {
  final _telephony = Telephony.instance;

  Future<void> startBackgroundService() async {
    await Workmanager().initialize(
      backgroundHandler, // The top level function, aka callbackDispatcher
    );

    await Workmanager().cancelByTag("update");

    await Workmanager().registerPeriodicTask(
      "update",
      "update",
      tag: "update",
      frequency: const Duration(minutes: 16),
    );
    if ((await _telephony.requestPhoneAndSmsPermissions) ?? false) {
      _telephony.listenIncomingSms(
          onNewMessage: (_) {}, onBackgroundMessage: backgroundMessageHandler);
    }
  }
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  print("start update by  call or sms");
  await update();
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

Future<void> update() async {
  print("background service --------- update...");
  if (!_requestLock.locked) {
    print("after update ");
    await _requestLock.synchronized(() async {
      try {
        // hive does not support multithreading
        await Hive.close();
        await setupDI();
      } catch (_) {
        GetIt.I.get<UxService>().reInitialize();
      }
      await GetIt.I.get<MessageRepo>().updatingMessages();
    });
  }
}
