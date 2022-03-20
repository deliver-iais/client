import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

final List<HctColor> _customHctColors = [
  HctColor.fromInt(Colors.orange.value),
  HctColor.fromInt(Colors.brown.value),
  HctColor.fromInt(Colors.yellow.value),
  HctColor.fromInt(Colors.yellowAccent.value),
  HctColor.fromInt(Colors.green.value),
  HctColor.fromInt(Colors.lightGreen.value),
  HctColor.fromInt(Colors.red.value),
  HctColor.fromInt(Colors.purple.value)
];

// TODO remove these
// ignore: constant_identifier_names
const LightThemeName = "Light";

// ignore: constant_identifier_names
const DarkThemeName = "Dark";

final palettes = [
  const Color(0xFF0060a7),
  const Color(0xff5c00a7),
  Colors.green,
  Colors.yellow,
];

ThemeScheme getThemeScheme(int index) =>
    ThemeScheme(CorePalette.of(palettes[index % palettes.length].value));

class ThemeScheme {
  final Material3ColorScheme _dark;
  final Material3ColorScheme _light;

  ThemeScheme(CorePalette palette)
      : _dark = Material3ColorScheme.lightOfCorePalette(palette),
        _light = Material3ColorScheme.darkOfCorePalette(palette);

  theme(bool isDark) => isDark ? getThemeData(_dark) : getThemeData(_light);

  extraTheme(bool isDark) => isDark
      ? getExtraThemeData(_dark, _customHctColors)
      : getExtraThemeData(_light, _customHctColors);
}
