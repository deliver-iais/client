import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key) {
    checkIfUsernameIsSet();
  }

  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  CheckPermissionsService _checkPermission =
  GetIt.I.get<CheckPermissionsService>();

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
    if (!await _accountRepo.usernameIsSet()) {
      _routingService.openAccountSettings(forceToSetUsernameAndName: true);
    }
  }
}
