import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (routingService.canPerformBackButton()) return true;
        routingService.pop();
        return false;
      },
      child: StreamBuilder(
          stream: routingService.currentRouteStream,
          builder: (context, snapshot) {
            return Row(
              children: [
                Container(
                    width: isLarge(context)
                        ? BREAKDOWN_SIZE / 2 + 84
                        : MediaQuery.of(context).size.width,
                    child: isLarge(context)
                        ? routingService.largePageNavigator(context)
                        : routingService.smallPageMain(context)),
                if (isLarge(context))
                  Expanded(
                      child: AnimatedSwitcher(
                    duration: ANIMATION_DURATION,
                    child: routingService.largePageMain(context),
                  ))
              ],
            );
          }),
    );
  }
}
