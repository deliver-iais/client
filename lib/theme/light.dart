import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const LightThemeName = "Light";

const _colorScheme = Material3ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0060a7),
  onPrimary: Color(0xFFffffff),
  primaryContainer: Color(0xFFd1e4ff),
  onPrimaryContainer: Color(0xFF001c38),
  secondary: Color(0xFF006874),
  onSecondary: Color(0xFFffffff),
  secondaryContainer: Color(0xFF90f1ff),
  onSecondaryContainer: Color(0xFF001f24),
  tertiary: Color(0xFF3c691b),
  onTertiary: Color(0xFFffffff),
  tertiaryContainer: Color(0xFFbcf293),
  onTertiaryContainer: Color(0xFF0b2000),
  error: Color(0xFFba1b1b),
  onError: Color(0xFFffffff),
  errorContainer: Color(0xFFffdad4),
  onErrorContainer: Color(0xFF410001),
  background: Color(0xFFfdfcff),
  onBackground: Color(0xFF1b1b1b),
  surface: Color(0xFFfdfcff),
  onSurface: Color(0xFF1b1b1b),
  surfaceVariant: Color(0xFFdfe2eb),
  onSurfaceVariant: Color(0xFF43474e),
  outline: Color(0xFF73777f),
  inverseSurface: Color(0xFF2f3033),
  onInverseSurface: Color(0xFFf1f0f3),
  primaryInverse: Color(0xFFd1e4ff),
);

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = getExtraThemeData(_colorScheme);

// ignore: non_constant_identifier_names
ThemeData LightTheme = getThemeData(_colorScheme);
