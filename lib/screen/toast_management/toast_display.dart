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
    Color? toastColor,
    bool isSaveToast = false,
    required BuildContext toastContext,
    required String toastText,
  }) {
    final fToast = FToast()..init(toastContext);
    final i18n = GetIt.I.get<I18N>();

    toastColor ??= Theme.of(toastContext).colorScheme.surface;
    final Widget toast = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: DEFAULT_BOX_SHADOWS,
        borderRadius: tertiaryBorder,
        color: toastColor,
      ),
      child:  Directionality(
        textDirection: i18n.defaultTextDirection,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (toastIcon != null) Icon(toastIcon),
            if (toastIcon != null)
              const SizedBox(
                width: 12.0,
              ),
            if (isSaveToast)
              Lottie.asset("assets/animations/file-save.json", width: 40),
            Expanded(
              child: Text(
                toastText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
