import 'dart:async';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:flutter/foundation.dart';
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
import 'dart:js' as js;
import "package:universal_html/js.dart" as ujs;


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

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
      final initialLink = await getInitialLink();
      if (initialLink.isNotEmpty) await handleJoinUri(context, initialLink);
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
    if(kIsWeb){
      js.context.callMethod("getNotificationPermission");
    }
    checkLogOutApp();
   checkAddToHomeInWeb(context);
    super.initState();
  }
  checkAddToHomeInWeb(BuildContext context)async {
    Timer(Duration(seconds: 3),(){
      try{
        final bool isDeferredNotNull =
        ujs.context.callMethod("isDeferredNotNull") as bool;
        if(isDeferredNotNull){
          //   ujs.context.callMethod("presentAddToHome");
          return true;

        }

      }catch(e){
        _logger.e(e);
      }
    });


  }

  checkLogOutApp() {
    _logOut.stream.listen((event) {
      if (event)
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (context) => IntroPage()));
    });
  }

  checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.length > 0) {
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
      _routingService.openAccountSettings(forceToSetUsernameAndName: true);
    } else {
      await _accountRepo.fetchProfile();
    }
  }
}
