import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/main.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class NotificationForegroundService {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  static final _i18n = GetIt.I.get<I18N>();

  ReceivePort? _receivePort;

  SendPort? _sendPort;

  ReceivePort? get getReceivePort => _receivePort;

  SendPort? get getSendPort => _sendPort;

  set setSendPort(SendPort? sp) => _sendPort = sp;

  bool foregroundNotification = false;

  NotificationForegroundService() {
    GetIt.I
        .get<SharedDao>()
        .getBooleanStream(SHARED_DAO_NOTIFICATION_FOREGROUND)
        .listen(
      (sif) async {
        foregroundNotification = sif;
        await foregroundService(foregroundNotification: foregroundNotification);
      },
    );
  }

  Future<void> toggleForegroundService() async {
    final foregroundNotification =
        await _sharedDao.toggleBoolean(SHARED_DAO_NOTIFICATION_FOREGROUND);
    await foregroundService(foregroundNotification: foregroundNotification);
  }

  Future<void> foregroundService({required bool foregroundNotification}) async {
    if (isAndroid) {
      if (foregroundNotification) {
        await _foregroundTaskInitializing();
      } else {
        await _stopForegroundTask();
      }
    }
  }

  Future<bool> callForegroundServiceStart() async {
    final foregroundNotification =
        await _sharedDao.getBoolean(SHARED_DAO_NOTIFICATION_FOREGROUND);
    if (!foregroundNotification) {
      return foregroundTaskInitializing();
    }
    return false;
  }

  Future<void> callForegroundServiceStop() async {
    final foregroundNotification =
        await _sharedDao.getBoolean(SHARED_DAO_NOTIFICATION_FOREGROUND);
    if (!foregroundNotification) {
      await _stopForegroundTask();
    }
  }

  Future<bool> _foregroundTaskInitializing() async {
    if (isAndroid) {
      await _initForegroundTask();
      if (await _startForegroundTask()) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<void> _initForegroundTask() async {
    final foregroundNotification =
        await _sharedDao.getBoolean(SHARED_DAO_NOTIFICATION_FOREGROUND);

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        isSticky: false,
        channelImportance: NotificationChannelImportance.NONE,
        visibility: NotificationVisibility.VISIBILITY_SECRET,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          if (foregroundNotification)
            NotificationButton(
              id: 'stopForegroundNotification',
              text: _i18n.get("notification_foreground_stop"),
            )
          else
            NotificationButton(
                id: 'stopForegroundNotification', text: _i18n.get("end_call")),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> foregroundTaskInitializing() async {
    if (isAndroid) {
      await _initForegroundTask();
      if (await _startForegroundTask()) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<bool> _startForegroundTask() async {
    final foregroundNotification =
        await _sharedDao.getBoolean(SHARED_DAO_NOTIFICATION_FOREGROUND);

    ReceivePort? receivePort;
    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: foregroundNotification
            ? _i18n.get("notification_foreground")
            : _i18n.get("notification_foreground_call"),
        notificationText: _i18n.get("notification_tap_to_return"),
        callback: foregroundNotification
            ? startCallbackNotification
            : startCallbackCallForeground,
      );
    }

    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      if (foregroundNotification) {
        receivePort.listen((message) async {
          if (message == "endForegroundNotification") {
            await _sharedDao.toggleBoolean(SHARED_DAO_NOTIFICATION_FOREGROUND);
            await _stopForegroundTask();
          } else {
            _logger.i('receive callStatus: $message');
          }
        });
      }
      return true;
    }

    return false;
  }

  Future<bool> _stopForegroundTask() async =>
      FlutterForegroundTask.stopService();
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallbackNotification() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(NotificationHandler());
}

class NotificationHandler extends TaskHandler {
  // ignore: prefer_typing_uninitialized_variables
  late final SendPort? sPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    sPort = sendPort;
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    final backgroundActivationTime =
        await FlutterForegroundTask.getData<String>(
      key: 'BackgroundActivationTime',
    );
    final appStatus =
        await FlutterForegroundTask.getData<String>(key: 'AppStatus');
    final isClosed =
        await FlutterForegroundTask.getData<String>(key: 'isClosed');
    final isReopen =
        await FlutterForegroundTask.getData<String>(key: 'isReopen');
    if (backgroundActivationTime != null &&
        int.parse(backgroundActivationTime) <
            clock.now().millisecondsSinceEpoch &&
        isClosed == null) {
      print(backgroundActivationTime);
      await dbSetupDI();
      registerSingleton<I18N>(I18N());
      await FlutterForegroundTask.updateService(
        notificationText: await getForeground("notification_foreground_not_received"),
        notificationTitle: await getForeground("notification_foreground_open_app"),
        callback: startCallbackNotification,
      );
      await FlutterForegroundTask.saveData(key: "isClosed", value: "True");
      await FlutterForegroundTask.removeData(key: "isReopen");
    } else if (appStatus != null &&
        isReopen == null &&
        appStatus == "Opened" &&
        backgroundActivationTime != null &&
        int.parse(backgroundActivationTime) >
            clock.now().millisecondsSinceEpoch) {
      await dbSetupDI();
      registerSingleton<I18N>(I18N());

      await FlutterForegroundTask.updateService(
        notificationTitle: await getForeground("notification_foreground"),
        notificationText: await getForeground("notification_tap_to_return"),
        callback: startCallbackNotification,
      );
      await FlutterForegroundTask.saveData(key: "isReopen", value: "True");
    }
  }

  Future<String> getForeground(String key) async {
    final isPersian = await FlutterForegroundTask.getData<bool>(key: 'Language') ?? true;
    switch(key){
      case "notification_foreground":
        return isPersian ? "دریافت نوتیفیکیشن های برنامه در پس زمینه فعال است" : "Notification Received On BackGround";
      case "notification_tap_to_return":
        return isPersian ? "برای بازگشت به برنامه کلیک کنید" : "Tap to return to the app";
      case "notification_foreground_not_received":
        return isPersian ? "نوتیفیکیشن های برنامه در پس زمینه فعال نمی باشند" : "Can't Received Notification On Background";
      case "notification_foreground_open_app":
        return isPersian ? "لطفا برنامه را مجدد باز کنید - بر روی نوار کلیک کنید" : "Please Open App Again - Tap Notification";
      default:
        return "";
    }
  }

  @override
  Future<void> onButtonPressed(String id) async {
    // Called when the notification button on the Android platform is pressed.
    final isClosed =
        await FlutterForegroundTask.getData<String>(key: 'isClosed');
    if (id == "stopForegroundNotification") {
      sPort?.send("endForegroundNotification");
      if (isClosed != null && isClosed == "True") {
        await FlutterForegroundTask.stopService();
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/");
    sPort?.send('onNotificationPressed');
  }
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallbackCallForeground() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(CallForegroundHandler());
}

class CallForegroundHandler extends TaskHandler {
  // ignore: prefer_typing_uninitialized_variables
  late final SendPort? sPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    sPort = sendPort;
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    if (id == "stopForegroundNotification") {
      sPort?.send("endCall");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/call-screen");
    sPort?.send('onNotificationPressed');
  }
}
