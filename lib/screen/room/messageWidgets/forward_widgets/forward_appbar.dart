import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ForwardAppbar extends StatelessWidget {
  final _routingServices = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return AppBar(
      leading: _routingServices.backButtonLeading(),
      title: Text(
        i18n.get("forward_to"),
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}
