import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/material.dart';

class ForwardAppbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return AppBar(
      title: Text(
        appLocalization.getTraslateValue("ForwardTo"),
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }
}
