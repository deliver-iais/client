import 'package:flutter/material.dart';

class ExtraThemeDataColorScheme {
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color secondaryContainer;
  final Color onSecondaryContainer;

  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  final Color errorContainer;
  final Color onErrorContainer;

  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color primaryInverse;

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
    required this.surfaceVariant,
    required this.onSurfaceVariant,
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
