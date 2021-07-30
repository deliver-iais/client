import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/methods/platform.dart';
import 'package:deliver_flutter/shared/methods/url.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';

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
    _notificationServices.cancelAllNotification();
    checkIfUsernameIsSet();

    if (isAndroid()) {
      checkShareFile(context);
    }
    if (isAndroid() || isIOS()) {
      initUniLinks(context);
    }

    super.initState();
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
      child: StreamBuilder(
          stream: _routingService.currentRouteStream,
          builder: (context, snapshot) {
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
