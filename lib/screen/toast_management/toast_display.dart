import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class ToastDisplay {
  static void showToast({
    IconData? toastIcon,
    bool showDoneAnimation = false,
    bool showWarningAnimation = false,
    BuildContext? toastContext,
    double maxWidth = 1000.0,
    Duration duration = SUPER_SLOW_ANIMATION_DURATION,
    required String toastText,
  }) {
    final i18n = GetIt.I.get<I18N>();

    final context = toastContext ?? GetIt.I.get<UxService>().appContext;

    final theme = Theme.of(context);

    maxWidth = min(context.size?.width ?? maxWidth, maxWidth);

    FToast().init(context);

    final Widget toast = Container(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: DEFAULT_BOX_SHADOWS,
        borderRadius: tertiaryBorder,
        color: theme.colorScheme.inverseSurface,
      ),
      child: Directionality(
        textDirection: i18n.defaultTextDirection,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (toastIcon != null) Icon(toastIcon),
            if (toastIcon != null)
              const SizedBox(
                width: 16.0,
              ),
            if (showDoneAnimation)
              const Ws.asset(
                "assets/animations/data.ws",
                width: 60,
                height: 40,
              ),
            if (showWarningAnimation)
              Ws.asset(
                "assets/animations/warning.ws",
                width: 60,
                height: 40,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      const ['Oval', '**'],
                      value: theme.colorScheme.onInverseSurface,
                    ),
                    ValueDelegate.strokeColor(
                      const ['**'],
                      value: theme.colorScheme.onInverseSurface,
                    ),
                    ValueDelegate.strokeColor(
                      const ["info1", '**'],
                      value: theme.colorScheme.inverseSurface,
                    ),
                    ValueDelegate.color(
                      const ["info2", '**'],
                      value: theme.colorScheme.inverseSurface,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Text(
                toastText,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    FToast().showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      fadeDuration: SLOW_ANIMATION_DURATION,
      toastDuration: duration * 4,
    );
  }
}
