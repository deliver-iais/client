import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastDisplay {
  static showToast(
      {IconData ? toastIcon,
      Color ? toastColor,
      required BuildContext tostContext,
     required String toastText}) {
    FToast fToast = FToast();
    fToast.init(tostContext);
    if (toastColor == null)
      toastColor = Theme.of(tostContext).scaffoldBackgroundColor;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(tostContext).dividerColor,
            blurRadius: 2,
          )
        ],
        borderRadius: BorderRadius.circular(10.0),
        color: toastColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (toastIcon != null) Icon(toastIcon),
          if (toastIcon != null)
            SizedBox(
              width: 12.0,
            ),
          Text(
            toastText,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

  }
}
