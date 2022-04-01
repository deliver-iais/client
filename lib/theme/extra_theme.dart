import 'dart:math';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ExtraThemeData {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  final Material3ColorScheme colorScheme;
  final List<CustomColorScheme> customColorsSchemeList;
  final CustomColorScheme primaryColorsScheme;
  final CustomColorScheme secondaryColorsScheme;
  final CustomColorScheme tertiaryColorsScheme;

  Color lowlight() => colorScheme.onPrimary;

  Color highlight() => colorScheme.primary;

  Color surfaceElevation(int number, {isSender = false}) => elevation(
      colorScheme.surface,
      isSender ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
      number);

  CustomColorScheme messageColorScheme(String uid) {
    if (_authRepo.isCurrentUser(uid)) {
      return primaryColorsScheme;
    }
    var hash = 0;
    for (var i = 0; i < uid.length; i++) {
      hash = uid.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (100);
    var r = Random(finalHash);
    return customColorsSchemeList[r.nextInt(customColorsSchemeList.length)];
  }

  ExtraThemeData(
      {required this.colorScheme, required this.customColorsSchemeList})
      : primaryColorsScheme = CustomColorScheme(
            colorScheme.primary,
            colorScheme.onPrimary,
            colorScheme.primaryContainer,
            colorScheme.onPrimaryContainer),
        secondaryColorsScheme = CustomColorScheme(
            colorScheme.secondary,
            colorScheme.onSecondary,
            colorScheme.secondaryContainer,
            colorScheme.onSecondaryContainer),
        tertiaryColorsScheme = CustomColorScheme(
            colorScheme.tertiary,
            colorScheme.onTertiary,
            colorScheme.tertiaryContainer,
            colorScheme.onTertiaryContainer);
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
