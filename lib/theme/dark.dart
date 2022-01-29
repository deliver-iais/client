import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const DarkThemeName = "Dark";

const _colorScheme = Material3ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF9fcaff),
  onPrimary: Color(0xFF00325b),
  primaryContainer: Color(0xFF004880),
  onPrimaryContainer: Color(0xFFd1e4ff),
  secondary: Color(0xFF4fd8eb),
  onSecondary: Color(0xFF00363d),
  secondaryContainer: Color(0xFF004f59),
  onSecondaryContainer: Color(0xFF90f1ff),
  tertiary: Color(0xFFa1d57a),
  onTertiary: Color(0xFF143800),
  tertiaryContainer: Color(0xFF255101),
  onTertiaryContainer: Color(0xFFbcf293),
  error: Color(0xFFffb4a9),
  onError: Color(0xFF680003),
  errorContainer: Color(0xFFffdad4),
  onErrorContainer: Color(0xFF410001),
  background: Color(0xFF1b1b1b),
  onBackground: Color(0xFFe2e2e6),
  surface: Color(0xFF1b1b1b),
  onSurface: Color(0xFFe2e2e6),
  surfaceVariant: Color(0xFF43474e),
  onSurfaceVariant: Color(0xFFc3c7d0),
  outline: Color(0xFF8d9199),
  inverseSurface: Color(0xFFe2e2e6),
  onInverseSurface: Color(0xFF1b1b1b),
  primaryInverse: Color(0xFF004880),
);

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = getExtraThemeData(_colorScheme);

// ignore: non_constant_identifier_names
ThemeData DarkTheme = getThemeData(_colorScheme);
