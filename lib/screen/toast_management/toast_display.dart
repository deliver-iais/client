import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class ToastDisplay {
  static void showToast({
    IconData? toastIcon,
    bool animateDone = false,
    BuildContext? toastContext,
    double maxWidth = 1000.0,
    Duration duration = SUPER_SLOW_ANIMATION_DURATION,
    required String toastText,
  }) {
    final i18n = GetIt.I.get<I18N>();
    if (toastContext != null) {
      maxWidth = toastContext.size!.width;
      FToast().init(toastContext);
    }

    final theme = Theme.of(FToast().context!);

    final Widget toast = Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: 200,
      ),
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
              const Ws.asset(
                "assets/animations/data.ws",
                width: 60,
                height: 40,
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
