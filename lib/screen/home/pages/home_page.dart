import 'dart:async';

import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
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
  final _coreServices = GetIt.I.get<CoreServices>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _uxService = GetIt.I.get<UxService>();
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _backgroundService = GetIt.I.get<BackgroundService>();

  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  @override
  void initState() {
    if (isMacOSNative) {
      GetIt.I.get<SeenDao>().watchAllRoomSeen().listen((event) {
        try {
          if (event.isNotEmpty) {
            FlutterAppBadger.updateBadgeCount(event.length);
          } else {
            FlutterAppBadger.removeBadge();
          }
        } catch (_) {}
      });
    }

    //this means user login successfully
    _analyticsService.sendLogEvent(
      "user_starts_app",
    );

    _coreServices.initStreamConnection();
    if (isMobileNative) {
      checkHaveShareInput(context);
      _notificationServices.cancelAllNotifications();
    }
    if (isWeb) {
      js.context.callMethod("getNotificationPermission", []);
    }
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
    if (isAndroidNative) _backgroundService.startBackgroundService();

    super.initState();
  }

  Future<void> checkAddToHomeInWeb(BuildContext context) async {
    Timer(const Duration(seconds: 3), () {
      try {
        // final bool isDeferredNotNull =
        //     js.context.callMethod("isDeferredNotNull", []) as bool;
        // TODO(any): add to home web
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
        shareTextMessage: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _uxService.updateHomeContext(context);
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (!_routingService.canPop()) {
          if (await FlutterForegroundTask.isRunningService) {
            FlutterForegroundTask.minimizeApp();
            return false;
          } else {
            return _routingService.maybePop();
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
      if(context.mounted) {
        showDialog(builder: (context) => NewFeatureDialog(), context: context)
          .ignore();
      }
      unawaited(_accountRepo.updatePlatformVersion());
    }
  }
}
