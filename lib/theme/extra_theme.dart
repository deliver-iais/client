import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class ExtraThemeData {
  Material3ColorScheme colorScheme;

  Color onDetailsBox;

  ExtraThemeData({
    required this.colorScheme,
    required this.onDetailsBox,
  });
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  const ExtraTheme({
    Key? key,
    required Widget child,
    required this.extraThemeData,
  }) : super(key: key, child: child);

  static ExtraThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ExtraTheme>()!
        .extraThemeData;
  }

  @override
  bool updateShouldNotify(ExtraTheme oldWidget) {
    return false;
  }
}
