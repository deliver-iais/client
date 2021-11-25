import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ForwardAppbar extends StatelessWidget {
  final _routingServices = GetIt.I.get<RoutingService>();
  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _routingServices.backButtonLeading(context),
      title: Text(
        i18n.get("forward_to"),
      ),
    );
  }
}
