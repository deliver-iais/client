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
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
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
          return true;
        }
        _routingService.maybePop();
        return false;
      },
      child: WithForegroundTask(
        child: Container(
          color: theme.colorScheme.background,
          child: _routingService.outlet(context),
        ),
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
