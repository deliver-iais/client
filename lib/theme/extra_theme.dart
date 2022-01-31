import 'dart:math';

import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class ExtraThemeData {
  final Material3ColorScheme colorScheme;
  final CustomColorScheme custom1;
  final CustomColorScheme custom2;
  final CustomColorScheme custom3;
  final CustomColorScheme custom4;
  final CustomColorScheme custom5;

  // TODO: Remove later on
  Color onDetailsBox;

  Color lowlight(bool isSender) =>
      !isSender ? colorScheme.onPrimary : colorScheme.onTertiary;

  Color highlight(bool isSender) =>
      !isSender ? colorScheme.primary : colorScheme.tertiary;

  Color surfaceElevation(int number, {isSender = false}) => elevation(
      colorScheme.surface,
      isSender ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
      number);

  Color avatarBackground(String uid) {
    var hash = 0;
    for (var i = 0; i < uid.length; i++) {
      hash = uid.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (100);
    var r = Random(finalHash);
    switch (r.nextInt(5)) {
      case 1:
        return custom2.primary;
      case 2:
        return custom3.primary;
      case 3:
        return custom4.primary;
      case 4:
        return custom5.primary;
      default:
        return custom1.primary;
    }
  }

  // TODO refactor this
  CustomColorScheme messageColorScheme(String uid) {
    var hash = 0;
    for (var i = 0; i < uid.length; i++) {
      hash = uid.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (100);
    var r = Random(finalHash);
    switch (r.nextInt(5)) {
      case 1:
        return custom2;
      case 2:
        return custom3;
      case 3:
        return custom4;
      case 4:
        return custom5;
      default:
        return custom1;
    }
  }

  ExtraThemeData({
    required this.colorScheme,
    required this.custom1,
    required this.custom2,
    required this.custom3,
    required this.custom4,
    required this.custom5,
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
