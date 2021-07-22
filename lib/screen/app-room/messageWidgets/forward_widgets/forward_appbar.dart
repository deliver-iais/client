import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ForwardAppbar extends StatelessWidget {
  final _routingServices = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    I18N appLocalization = I18N.of(context);
    return AppBar(
      leading: _routingServices.backButtonLeading(),
      title: Text(
        appLocalization.get("forward_to"),
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }
}
