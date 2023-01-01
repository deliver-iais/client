import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<T?> showContinueAbleDialog<T>(String titleKey, {BuildContext? context}) {
  final i18n = GetIt.I.get<I18N>();
  final routingService = GetIt.I.get<RoutingService>();

  // Assert in debug mode!
  assert(
    (context ?? routingService.mainNavigatorState.currentContext) != null,
    "at least one of `context` or `routingService.mainNavigatorState.currentContext` should be defined",
  );

  if ((context ?? routingService.mainNavigatorState.currentContext) == null) {
    return Future.value(); // Just Ignore
  }

  final ctx = context ?? routingService.mainNavigatorState.currentContext!;

  return showTitledDialog(
    titleKey,
    context: ctx,
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(ctx);
        },
        child: Text(
          i18n.get("continue"),
        ),
      )
    ],
  );
}

Future<T?> showTitledDialog<T>(
  String titleKey, {
  List<Widget> actions = const [],
  BuildContext? context,
}) {
  final i18n = GetIt.I.get<I18N>();
  final routingService = GetIt.I.get<RoutingService>();

  // Assert in debug mode!
  assert(
    (context ?? routingService.mainNavigatorState.currentContext) != null,
    "at least one of `context` or `routingService.mainNavigatorState.currentContext` should be defined",
  );

  if ((context ?? routingService.mainNavigatorState.currentContext) == null) {
    return Future.value(); // Just Ignore
  }

  final ctx = context ?? routingService.mainNavigatorState.currentContext!;

  return showDialog(
    context: ctx,
    useSafeArea: true,
    builder: (context) {
      return AlertDialog(
        actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
        content: SizedBox(
          width: 200,
          child: Text(
            i18n.get(titleKey),
            textDirection: i18n.defaultTextDirection,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
        ),
        actions: actions,
      );
    },
  );
}
