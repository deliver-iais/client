import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

final ACTIVE_COLOR = Colors.greenAccent.shade700;

const LIGHT_BOX_SHADOWS = [
  BoxShadow(
    color: Color(0x10000000),
    spreadRadius: 2,
    blurRadius: 6,
    offset: Offset(0, 2),
  )
];

const DEFAULT_BOX_SHADOWS = [
  BoxShadow(
    color: Color(0x20000000),
    spreadRadius: 2,
    blurRadius: 3,
    offset: Offset(0, 2),
  ),
];

final palettes = [
  const Color(0xFF0060a7),
  const Color(0xff5c00a7),
  Colors.green,
  Colors.yellow,
  const Color(0xffd36c98),
  const Color(0xffdda822),
  const Color(0xffc45245),
  Colors.blueGrey,
];
final BackgroundPalettes = [
  const Color(0xffacd0d7),
  const Color(0xffcdd8fa),
  const Color(0xffcef691),
  const Color(0xfff13804),
  const Color(0xFFFF0494),
  const Color(0xffdda822),
  const Color(0xffc45245),
  Colors.blueGrey,
];

final patterns = [
  "pattern-1",
  "pattern-2",
  "pattern-3",
  "pattern-4",
  "pattern-5",
  "pattern-6",
  "pattern-7",
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
