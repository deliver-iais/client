import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

// ignore: non_constant_identifier_names
final ActiveColor = Colors.greenAccent.shade700;

// ignore: non_constant_identifier_names
final DefaultBoxShadows = [
  BoxShadow(
    color: Colors.black.withOpacity(0.1),
    spreadRadius: 2,
    blurRadius: 3,
    offset: const Offset(0, 3), // changes position of shadow
  ),
];

List<BoxShadow> shadowElevation(double level) {
  return [
    BoxShadow(
      color: Colors.black.withOpacity(0.1 * level),
      spreadRadius: 2 * level,
      blurRadius: 3 * level,
      offset: const Offset(0, 3), // changes position of shadow
    ),
  ];
}

final palettes = [
  const Color(0xFF0060a7),
  const Color(0xff5c00a7),
  Colors.green,
  Colors.yellow,
];

final patterns = [
  "pattern-1",
  "pattern-2",
  "pattern-3",
];

ThemeScheme getThemeScheme(int index) =>
    ThemeScheme(CorePalette.of(palettes[index % palettes.length].value));

class ThemeScheme {
  final Material3ColorScheme _dark;
  final Material3ColorScheme _light;

  ThemeScheme(CorePalette palette)
      : _dark = Material3ColorScheme.darkOfCorePalette(palette),
        _light = Material3ColorScheme.lightOfCorePalette(palette);

  ThemeData theme({bool isDark = false}) =>
      isDark ? getThemeData(_dark) : getThemeData(_light);

  ExtraThemeData extraTheme({bool isDark = false}) =>
      isDark ? getExtraThemeData(_dark) : getExtraThemeData(_light);
}
