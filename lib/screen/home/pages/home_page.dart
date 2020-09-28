import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  final _routingService = GetIt.I.get<RoutingService>();

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
            return Row(
              children: [
                Container(
                    width: isLarge(context)
                        ? BREAKDOWN_SIZE / 2 + 84
                        : MediaQuery.of(context).size.width,
                    child: isLarge(context)
                        ? _routingService.largePageNavigator(context)
                        : _routingService.smallPageMain(context)),
                if (isLarge(context))
                  Expanded(child: _routingService.largePageMain(context))
              ],
            );
          }),
    );
  }
}
