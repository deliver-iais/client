import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
  final _callRepo = GetIt.I.get<CallRepo>();
  final _callService = GetIt.I.get<CallService>();

  ReceivePort? _receivePort;

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

  @override
  void initState() {
    _callService.isUserOnCall.stream.listen((event) {
      if (event) {
        _foregroundTaskInitializing();
      } else {
        _stopForegroundTask();
      }
    });

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

    ReceiveSharingIntent.getInitialText().then((value) async {
      if (value != null && value.isNotEmpty) {
        _urlHandlerService.handleApplicationUri(
          value,
          context,
          shareTextMessage: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (!_routingService.canPop()) {
          if(await FlutterForegroundTask.isRunningService){
            FlutterForegroundTask.minimizeApp();
            return false;
          }else{
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

  Future<void> _foregroundTaskInitializing() async {
    if (isAndroid) {
      await _initForegroundTask();
      await _startForegroundTask();
    }
  }

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: false,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'endCall', text: 'End Call'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: '$APPLICATION_NAME Call on BackGround',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message == "endCall") {
          _callRepo.endCall();
        } else {
          _logger.i('receive callStatus: $message');
        }
      });

      return true;
    }

    return false;
  }

  Future<bool> _stopForegroundTask() async =>
      FlutterForegroundTask.stopService();
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
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
    if (id == "endCall") {
      sPort?.send("endCall");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }
}
