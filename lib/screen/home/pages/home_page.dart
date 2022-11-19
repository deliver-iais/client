import 'dart:async';

import 'dart:ui';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:workmanager/workmanager.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:telephony/telephony.dart';

// import 'package:sms_advanced/sms_advanced.dart';
//
@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  print("back sms" + (message.body ?? "body"));
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask() async {
  PhoneState.phoneStateStream.listen((event) {
    print("incoming call in fetch...........");
  });
  print("start back");
  // Do your work here...
  // BackgroundFetch.finish(taskId);
}

@pragma('vm:entry-point')
start(er) async {
  // PhoneState.phoneStateStream.listen((event) {
  //   print("incoming call in backround");
  // });
  print("start back");
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _logger = GetIt.I.get<Logger>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _uxService = GetIt.I.get<UxService>();
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  final telephony = Telephony.instance;

  void _addLifeCycleListener() {
    if (isDesktop) {
      DesktopLifecycle.instance.isActive.addListener(() {
        if (DesktopLifecycle.instance.isActive.value) {
          _coreServices.checkConnectionTimer();
        }
      });
    } else {
      SystemChannels.lifecycle.setMessageHandler((message) async {
        if (message != null &&
            message == AppLifecycleState.resumed.toString()) {
          _coreServices.checkConnectionTimer();
        }
        return message;
      });
    }
  }

  init() async {
    await Permission.phone.request();

    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.oneShot(
        Duration(seconds: 1), 2, backgroundFetchHeadlessTask,
        wakeup: true, rescheduleOnReboot: true);

    // int status = await BackgroundFetch.configure(BackgroundFetchConfig(
    //   minimumFetchInterval: 15,
    //   stopOnTerminate: false,
    //   enableHeadless: true,
    //   requiresBatteryNotLow: false,
    //   requiresCharging: false,
    //   requiresStorageNotLow: false,
    //   requiresDeviceIdle: false,
    //   // requiredNetworkType: NetworkType.NONE
    // ), (String taskId) async { // <-- Event handler
    //   // This is the fetch-event callback.
    //   print("[BackgroundFetch] Event received $taskId");
    //
    //   // IMPORTANT:  You must signal completion of your task or the OS can punish your app
    //   // for taking too long in the background.
    //   BackgroundFetch.finish(taskId);
    // }, (String taskId) async { // <-- Task timeout handler.
    //   // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
    //   print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    //   BackgroundFetch.finish(taskId);
    // });
    // print('[BackgroundFetch] configure success: $status');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    // BackgroundFetch.start();

    // final service = FlutterBackgroundService();
    // await service.configure(
    //   androidConfiguration: AndroidConfiguration(
    //     // this will be executed when app is in foreground or background in separated isolate
    //     onStart: start,
    //
    //     // auto start service
    //     autoStart: true,
    //     isForegroundMode: true,
    //
    //     // notificationChannelId: 'my_foreground',
    //     // initialNotificationTitle: 'AWESOME SERVICE',
    //     // initialNotificationContent: 'Initializing',
    //     // foregroundServiceNotificationId: 888,
    //   ),
    //   iosConfiguration: IosConfiguration(
    //       // auto start service
    //       // autoStart: true,
    //       //
    //       // // this will be executed when app is in foreground in separated isolate
    //       // onForeground: onStart,
    //
    //       // you have to enable background fetch capability on xcode project
    //       // onBackground: onIosBackground,
    //       ),
    // );
    //
    // await service.startService();
  }

  @override
  void initState() {
    // init();
    // Workmanager().initialize(
    //   callbackDispatcher, // The top level function, aka callbackDispatcher
    //   //     true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    // );
    // Workmanager().executeTask((taskName, inputData) {});

    // Telephony.backgroundInstance.listenIncomingSms(
    //     onNewMessage: (e) => {}, onBackgroundMessage: backgroundMessageHandler);
    // Workmanager().registerPeriodicTask(
    //   "updating",
    //   "updating",
    //   frequency: const Duration(hours: 1),
    // );
    //
    // telephony.listenIncomingSms(
    //   onBackgroundMessage: backgroundMessageHandler,
    //   onNewMessage: (SmsMessage message) {
    //     print("new message" + (message.body ?? ""));
    //   },
    // );

    Workmanager().registerOneOffTask("simple", "simple");

    FToast().init(context);
    //this means user login successfully
    if (hasFirebaseCapability) {
      //its work property without VPN
      FirebaseAnalytics.instance.logEvent(name: "user_starts_app");
    }
    if (mounted) {
      toggleTheme();
    }

    window.onPlatformBrightnessChanged = () {
      toggleTheme();
    };
    _coreServices.initStreamConnection();
    if (isAndroid || isIOS) {
      checkHaveShareInput(context);
      _notificationServices.cancelAllNotifications();
    }
    if (isWeb) {
      js.context.callMethod("getNotificationPermission", []);
    }
    checkIfVersionChange();
    checkAddToHomeInWeb(context);

    _addLifeCycleListener();

    _contactRepo.sendNotSyncedContactInStartTime();

    super.initState();
  }

  void toggleTheme() {
    setState(() {
      if (_uxService.isAutoNightModeEnable) {
        window.platformBrightness == Brightness.dark
            ? _uxService.toggleThemeToDarkMode()
            : _uxService.toggleThemeToLightMode();
      }
    });
  }

  Future<void> checkAddToHomeInWeb(BuildContext context) async {
    Timer(const Duration(seconds: 3), () {
      try {
        // final bool isDeferredNotNull =
        //     js.context.callMethod("isDeferredNotNull", []) as bool;
        //todo add to home web
        // if (isDeferredNotNull != nnulisDeferredNotNull) {
        //   //   ujs.context.callMethod("presentAddToHome");
        //   // return true;
        //
        // }
      } catch (e) {
        _logger.e(e);
      }
    });
  }

  void _shareInputFile(List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      _routingService.openShareInput(paths: files.map((e) => e.path).toList());
    }
  }

  void checkHaveShareInput(BuildContext context) {
    ReceiveSharingIntent.getMediaStream().listen((event) {
      _shareInputFile(event);
    });

    ReceiveSharingIntent.getInitialMedia().then((value) {
      _shareInputFile(value);
    });
    ReceiveSharingIntent.getTextStream().listen((event) {
      _shareInputText(event, context);
    });
    ReceiveSharingIntent.getInitialText().then((value) async {
      _shareInputText(value, context);
    });
  }

  void _shareInputText(String? value, BuildContext context) {
    if (value != null && value.isNotEmpty) {
      _urlHandlerService.handleApplicationUri(
        value,
        context,
        shareTextMessage: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (!_routingService.canPop() &&
            _routingService.preMaybePopScopeValue()) {
          if (await FlutterForegroundTask.isRunningService) {
            FlutterForegroundTask.minimizeApp();
            return false;
          } else {
            return true;
          }
        }
        _routingService.maybePop();
        return false;
      },
      child: Container(
        color: theme.colorScheme.background,
        child: _routingService.outlet(context),
      ),
    );
  }

  Future<void> checkIfVersionChange() async {
    if (await _accountRepo.shouldShowNewFeatureDialog()) {
      showDialog(builder: (context) => NewFeatureDialog(), context: context)
          .ignore();
    }
  }
}
