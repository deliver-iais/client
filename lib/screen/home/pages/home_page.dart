import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/screen/intro/pages/intro_page.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _logger = GetIt.I.get<Logger>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  BehaviorSubject<bool> _logOut = BehaviorSubject.seeded(false);

  Future<void> initUniLinks(BuildContext context) async {
    try {
      String? initialLink = await getInitialLink();
      if (initialLink != null && initialLink.isNotEmpty)
        await handleJoinUri(context, initialLink);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  void initState() {
    _coreServices.initStreamConnection();
    _notificationServices.cancelAllNotifications();
    checkIfUsernameIsSet();

    if (isAndroid()) {
      checkShareFile(context);
    }
    if (isAndroid() || isIOS()) {
      initUniLinks(context);
    }
    checkLogOutApp();
    super.initState();
  }

  checkLogOutApp() {
    _logOut.stream.listen((event) {
      if (event)
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => IntroPage()), (e) => false);
    });
  }

  checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.length > 0) {
        List<String> paths = [];
        for (var path in value) {
          paths.add(path.path);
        }
        _routingService.openShareFile(context, path: paths);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_routingService.canPerformBackButton()) return true;
        _routingService.pop();
        return false;
      },
      child: StreamBuilder<String>(
          stream: _routingService.currentRouteStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == LOG_OUT) {
              _logOut.add(true);
              _routingService.reset();
              return SizedBox.shrink();
            }
            return _routingService.routerOutlet(context);
          }),
    );
  }

  void checkIfUsernameIsSet() async {
    if (!await _accountRepo.getProfile(retry: true)) {
      _routingService.openAccountSettings(context,
          forceToSetUsernameAndName: true);
    } else {
      await _accountRepo.fetchProfile();
    }
  }
}
