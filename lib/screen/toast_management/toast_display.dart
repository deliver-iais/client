import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    toastColor ??= Theme.of(toastContext).colorScheme.surface;
    final Widget toast = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(toastContext).dividerColor,
            blurRadius: 16,
          )
        ],
        borderRadius: mainBorder,
        color: toastColor,
      ),
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
          Text(
            toastText,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
