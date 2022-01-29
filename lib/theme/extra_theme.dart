import 'package:flutter/material.dart';

class ExtraThemeDataColorScheme {
  Color primaryContainer;
  Color onPrimaryContainer;

  Color secondaryContainer;
  Color onSecondaryContainer;

  Color tertiary;
  Color onTertiary;
  Color tertiaryContainer;
  Color onTertiaryContainer;

  Color errorContainer;
  Color onErrorContainer;

  Color inverseSurface;
  Color onInverseSurface;
  Color primaryInverse;

  ExtraThemeDataColorScheme({
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.primaryInverse,
  });
}

class ExtraThemeData {
  ExtraThemeDataColorScheme colorScheme;

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
