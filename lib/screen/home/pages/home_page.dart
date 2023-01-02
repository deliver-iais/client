import 'dart:async';

import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/methods/dialog.dart';
import 'package:deliver/shared/methods/platform.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _notificationServices = GetIt.I.get<NotificationServices>();

  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();
  final _backgroundService = GetIt.I.get<BackgroundService>();

  @override
  void initState() {
    FToast().init(context);
    //this means user login successfully
    if (hasFirebaseCapability) {
      //its work property without VPN
      FirebaseAnalytics.instance.logEvent(name: "user_starts_app");
    }

    _coreServices.initStreamConnection();
    if (isAndroid || isIOS) {
      checkHaveShareInput(context);
      _notificationServices.cancelAllNotifications();
    }
    if (isWeb) {
      js.context.callMethod("getNotificationPermission", []);
    }

    checkRefreshToken();

    checkIfVersionChange();
    checkAddToHomeInWeb(context);

    _appLifecycleService
      ..startLifeCycListener()
      ..watchAppAppLifecycle().listen((event) {
        if (event == AppLifecycle.RESUME) {
          _coreServices.checkConnectionTimer();
        }
      });

    _contactRepo.sendNotSyncedContactInStartTime();
    if (isAndroid) _backgroundService.startBackgroundService();

    super.initState();
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
      unawaited(_accountRepo.updatePlatformVersion());
    }
  }

  Future<void> checkRefreshToken() async {
    await checkRefreshTokenExpiration();
    await checkRefreshTokenEmptiness();
  }

  Future<void> checkRefreshTokenExpiration() async {
    if (_authRepo.isRefreshTokenExpired()) {
      // Delay for displaying dialog
      await Future.delayed(const Duration(seconds: 1));

      await showContinueAbleDialog(
        "your_session_is_expired_please_login_again",
        context: context,
      );
      return _routingService.logout();
    }
  }

  Future<void> checkRefreshTokenEmptiness() async {
    if (_authRepo.isRefreshTokenEmpty()) {
      // Delay for displaying dialog
      await Future.delayed(const Duration(seconds: 1));

      await showContinueAbleDialog(
        "your_session_is_has_a_problem",
        context: context,
      );
      return _routingService.logout();
    }
  }
}
