import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class ToastDisplay {
  static void showToast({
    IconData? toastIcon,
    bool animateDone = false,
    BuildContext ? toastContext,
    required String toastText,
  }) {
    final i18n = GetIt.I.get<I18N>();

    final theme = Theme.of(FToast().context!);

    final Widget toast = Container(
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
                width: 12.0,
              ),
            if (animateDone)
              Lottie.asset("assets/animations/done.zip", width: 60, height: 40),
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
      toastDuration: SUPER_SLOW_ANIMATION_DURATION * 4,
    );
  }
}
