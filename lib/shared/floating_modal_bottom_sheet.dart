import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {

    return Center(
      heightFactor: 1,
      child: SizedBox(
        width: min(MediaQuery.of(context).size.width, 400),
        // height: 100,
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.only(
            topLeft: mainBorder.topLeft,
            topRight: mainBorder.topLeft,
          ),
          child: child,
        ),
      ),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  final result = await showCustomModalBottomSheet(
    context: context,
    builder: builder,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    useRootNavigator: true,
    containerWidget: (_, animation, child) => FloatingModal(
      child: child,
    ),
    expand: false,
  );

  return result;
}

void showQrCode(BuildContext context, String url) {
  final i18n = GetIt.I.get<I18N>();
  showFloatingModalBottomSheet(
    context: context,
    builder: (context) => Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 20.0, end: 20.0, start: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: QrImage(
                data: url,
                padding: EdgeInsets.zero,
                foregroundColor: Colors.black,
              ),
            ),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsetsDirectional.only(top: 10.0),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(i18n.get("skip")),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
