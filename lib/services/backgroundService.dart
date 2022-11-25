import 'package:deliver/main.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

final _requestLock = Lock();

class BackgroundService {
  final _telephony = Telephony.instance;
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();

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
      frequency: const Duration(minutes: 30),
    );
    _appLifecycleService.appInPermissionState = true;

    if (await (_telephony.requestPhoneAndSmsPermissions) ?? false) {
      _appLifecycleService.appInPermissionState = false;
      _telephony.listenIncomingSms(
        onNewMessage: (_) {},
        onBackgroundMessage: backgroundMessageHandler,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
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
  await _requestLock.synchronized(() async {
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
    } catch (_) {}
  });
}
