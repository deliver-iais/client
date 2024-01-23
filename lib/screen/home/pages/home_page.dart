import 'dart:async';

import 'package:deliver/box/call_data_usage.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:deliver/screen/settings/account_settings.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/utils/call_utils.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _i18n = GetIt.I.get<I18N>();

  final _routingService = GetIt.I.get<RoutingService>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _backgroundService = GetIt.I.get<BackgroundService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();

  @override
  void initState() {
    _coreServices.initStreamConnection();
    _messageRepo.createConnectionStatusHandler();
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

    PerformanceMonitor.performanceProfile.pairwise().listen((mode) {
      if (mode[0].level > mode[1].level &&
          mode[1] == PerformanceMode.POWER_SAVER) {
        ToastDisplay.showToast(
          toastText: _i18n["power_saver_turned_on"],
          showWarningAnimation: true,
          maxWidth: 400,
        );
      } else if (mode[0].level < mode[1].level &&
          mode[0] == PerformanceMode.POWER_SAVER) {
        ToastDisplay.showToast(
          toastText: _i18n["power_saver_turned_off"],
          showWarningAnimation: true,
          maxWidth: 400,
        );
      }
    });

    //this means user login successfully
    _analyticsService.sendLogEvent(
      "user_starts_app",
    );
    if (isMobileNative) {
      checkHaveShareInput(context);
      _notificationServices.cancelAllNotifications();
    }
    if (isWeb) {
      js.context.callMethod("getNotificationPermission", []);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkHasProfile();
        checkIfVersionChange();
      }
    });

    _appLifecycleService
      ..startLifeCycListener()
      ..lifecycleStream.listen((event) {
        if (event == AppLifecycle.ACTIVE) {
          _coreServices.checkConnectionTimer();
        }
      });

    _contactRepo.sendNotSyncedContactInStartTime();
    if (isAndroidNative) {
      // _backgroundService.startBackgroundService();
    }
    _fireBaseServices.sendFireBaseToken().ignore();
    super.initState();
  }

  Future<void> _checkHasProfile() async {
    if (!await _accountRepo.hasProfile()) {
      if (context.mounted) {
        unawaited(
          (Navigator.pushReplacement(
            settings.appContext,
            MaterialPageRoute(
              builder: (c) {
                return const AccountSettings(
                  forceToSetName: true,
                );
              },
            ),
          )),
        );
      }
    }
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
    settings.updateAppContext(context);

    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (!_routingService.canPop()) {
          if (await FlutterForegroundTask.isRunningService) {
            if (settings.inLocalNetwork.value &&
                !(await CallUtils.hasSystemAlertWindowPermission())) {
              await CallUtils.checkForSystemAlertWindowPermission(showCallAlarm: true);
            } else {
              FlutterForegroundTask.minimizeApp();
              return false;
            }
          } else {
            return _routingService.maybePop();
          }
        }
        unawaited(_routingService.maybePop());
        return false;
      },
      child: Container(
        color: theme.colorScheme.background,
        child: _routingService.outlet(context),
      ),
    );
  }

  void checkIfVersionChange() {
    if (_accountRepo.shouldShowNewFeatureDialog()) {
      if (context.mounted) {
        showDialog(builder: (context) => NewFeatureDialog(), context: context)
            .ignore();
      }
      unawaited(_accountRepo.updatePlatformVersion());
    }
  }
}
