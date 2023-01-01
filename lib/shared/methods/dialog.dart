import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<T?> showCancelableAbleDialog<T>(
  String titleKey, {
  String okTextKey = "ok",
  BuildContext? context,
}) {
  final i18n = GetIt.I.get<I18N>();

  final ctx = _checkAndGetBuildContext(context);

  if (ctx == null) {
    return Future.value(); // Just Ignore
  }

  return showTitledDialog(
    titleKey,
    context: ctx,
    actions: (c) => [
      TextButton(
        onPressed: () {
          Navigator.pop(c, true);
        },
        child: Text(
          i18n.get(okTextKey),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(c, false);
        },
        child: Text(
          i18n.get("cancel"),
        ),
      )
    ],
  );
}

Future<T?> showContinueAbleDialog<T>(String titleKey, {BuildContext? context}) {
  final i18n = GetIt.I.get<I18N>();

  final ctx = _checkAndGetBuildContext(context);

  if (ctx == null) {
    return Future.value(); // Just Ignore
  }

  return showTitledDialog(
    titleKey,
    context: ctx,
    actions: (c) => [
      TextButton(
        onPressed: () {
          Navigator.pop(c);
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
  required List<Widget> Function(BuildContext) actions,
  BuildContext? context,
}) {
  final i18n = GetIt.I.get<I18N>();

  final ctx = _checkAndGetBuildContext(context);

  if (ctx == null) {
    return Future.value(); // Just Ignore
  }

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
        actions: actions(ctx),
      );
    },
  );
}

BuildContext? _checkAndGetBuildContext(BuildContext? context) {
  final routingService = GetIt.I.get<RoutingService>();

  // Assert in debug mode!
  assert(
    (context ?? routingService.mainNavigatorState.currentContext) != null,
    "at least one of `context` or `routingService.mainNavigatorState.currentContext` should be defined",
  );

  return context ?? routingService.mainNavigatorState.currentContext;
}
