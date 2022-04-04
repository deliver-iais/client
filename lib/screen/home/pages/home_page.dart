import 'dart:async';
import 'dart:ui';

import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/url.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _logger = GetIt.I.get<Logger>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _uxService = GetIt.I.get<UxService>();

  Future<void> initUniLinks(BuildContext context) async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null && initialLink.isNotEmpty) {
        // ignore: use_build_context_synchronously
        await handleJoinUri(context, initialLink);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  void initState() {
    window.onPlatformBrightnessChanged = () {
      setState(() {
        if (_uxService.isAutoNightModeEnable) {
          window.platformBrightness == Brightness.dark
              ? _uxService.toggleThemeToDarkMode()
              : _uxService.toggleThemeToLightMode();
        }
      });
    };
    _coreServices.initStreamConnection();
    if (isAndroid || isIOS) {
      _notificationServices.cancelAllNotifications();
    }
    if (isAndroid) {
      checkShareFile(context);
    }
    if (isAndroid || isIOS) {
      initUniLinks(context);
    }
    if (isWeb) {
      js.context.callMethod("getNotificationPermission", []);
    }
    checkIfVersionChange();
    checkAddToHomeInWeb(context);

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

  void checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        final paths = <String>[];
        for (final path in value) {
          paths.add(path.path);
        }
        _routingService.openShareFile(path: paths);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (!_routingService.canPop()) return true;
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
      showDialog(builder: (context) => NewFeatureDialog(), context: context);
    }
  }
}
