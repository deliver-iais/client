import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class ExtraThemeData {
  Material3ColorScheme colorScheme;

  Color onDetailsBox;

  Color lowlight(bool isSender) =>
      !isSender ? colorScheme.onPrimary : colorScheme.onTertiary;

  Color highlight(bool isSender) =>
      !isSender ? colorScheme.primary : colorScheme.tertiary;

  Color surfaceElevation(int number, {isSender = false}) => elevation(
      colorScheme.surface,
      isSender ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
      number);

  Color messageBackground(isSender) =>
      isSender ? colorScheme.tertiaryContainer : colorScheme.primaryContainer;

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
  bool updateShouldNotify(ExtraTheme oldWidget) => false;
}
