import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const FloatingModal({Key key, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Container(
        width: min(MediaQuery.of(context).size.width, 400),
        // height: 100,
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20)),
          child: child,
        ),
      ),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  BuildContext context,
  WidgetBuilder builder,
  Color backgroundColor,
  bool isDismissible = true
}) async {
  final result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      isDismissible: isDismissible,
      containerWidget: (_, animation, child) => FloatingModal(
            child: child,
          ),
      expand: false);

  return result;
}

void showQrCode(BuildContext context, String url) {
  print(url);
  showFloatingModalBottomSheet(
    context: context,
    builder: (context) => Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: QrImage(
                data: url,
                version: QrVersions.auto,
                padding: EdgeInsets.zero,
                foregroundColor: Colors.black,
              ),
            ),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.only(top: 10.0),
              child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      Text(I18N.of(context).get("skip"))),
            ),
          ],
        ),
      ),
    ),
  );
}
