import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastDisplay {
  static showToast(
      {IconData? toastIcon,
      Color? toastColor,
      required BuildContext toastContext,
      required String toastText}) {
    FToast fToast = FToast();
    fToast.init(toastContext);
    toastColor ??= Theme.of(toastContext).colorScheme.surface;
    Widget toast = Container(
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
