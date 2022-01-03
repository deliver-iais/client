import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/screen/intro/pages/intro_page.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:flutter/material.dart';
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
  final BehaviorSubject<bool> _logOut = BehaviorSubject.seeded(false);

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
    checkLogOutApp();
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

  checkLogOutApp() {
    _logOut.stream.listen((event) {
      if (event) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const IntroPage()),
            (e) => false);
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
        if (_routingService.isInRoomPage()) _routingService.maybePop();
        return false;
      },
      child: _routingService.outlet(context),
    );
  }

  void checkIfUsernameIsSet() async {
    if (!await _accountRepo.getProfile(retry: true)) {
      _routingService.openAccountSettings(forceToSetUsernameAndName: true);
    } else {
      await _accountRepo.fetchProfile();
    }
  }
}
