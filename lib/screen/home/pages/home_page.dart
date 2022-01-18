import 'dart:async';
import 'package:deliver/screen/intro/widgets/new_feature_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';
import 'package:universal_html/html.dart' as html;
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;

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
  bool shouldShowNewFeatureDialog = false;

  Future<void> initUniLinks(BuildContext context) async {
    try {
      String? initialLink = await getInitialLink();
      if (initialLink != null && initialLink.isNotEmpty) {
        await handleJoinUri(context, initialLink);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  void initState() {
    if (kIsWeb) {
      html.document.onContextMenu.listen((event) => event.preventDefault());
    }

    _coreServices.initStreamConnection();
    if (isAndroid() || isIOS()) {
      _notificationServices.cancelAllNotifications();
    }

    checkIfUsernameIsSet();
    if (isAndroid()) {
      checkShareFile(context);
    }
    if (isAndroid() || isIOS()) {
      initUniLinks(context);
    }
    if (kIsWeb) {
      js.context.callMethod("getNotificationPermission", []);
    }
    checkIfVersionChange();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (true) {
        showDialog(
            builder: (context) => const NewFeatureDialog(), context: context);
      }
    });
    checkAddToHomeInWeb(context);

    super.initState();
  }

  checkAddToHomeInWeb(BuildContext context) async {
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

  checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        List<String> paths = [];
        for (var path in value) {
          paths.add(path.path);
        }
        _routingService.openShareFile(path: paths);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_routingService.canPop()) return true;
        _routingService.maybePop();
        return false;
      },
      child: _routingService.outlet(context),
    );
  }

  void checkIfUsernameIsSet() async {
    if (!await _accountRepo.hasProfile(retry: true)) {
      _routingService.openAccountSettings(forceToSetUsernameAndName: true);
    } else {
      await _accountRepo.fetchProfile();
    }
  }

  void checkIfVersionChange() async {
    if (await _accountRepo.shouldShowNewFeatureDialog()) {
      shouldShowNewFeatureDialog = true;
    }
  }
}
