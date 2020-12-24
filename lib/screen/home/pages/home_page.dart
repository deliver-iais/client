import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  var _notificationServices = GetIt.I.get<NotificationServices>();

  @override
  void initState() {
    super.initState();
    _notificationServices.reset("\t");
    checkIfUsernameIsSet();
    if (isAndroid()) {
      checkShareFile(context);
    }
    _coreServices.initStreamConnection();
  }

  checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value != null) {
        List<String> paths = List();
        for (var path in value) {
          paths.add(path.path);
        }
        ExtendedNavigator.of(context).pushAndRemoveUntil(
            Routes.shareInputFile, (_) => false,
            arguments: ShareInputFileArguments(inputSharedFilePath: paths));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _notificationServices.reset("\t");
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
    if (!await _accountRepo.usernameIsSet()) {
      _routingService.openAccountSettings(forceToSetUsernameAndName: true);
    }
  }
}
