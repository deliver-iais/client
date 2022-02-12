import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

final corePalette = CorePalette.of(0xFF0060a7);

final _colorSchemeLight = Material3ColorScheme.lightOfCorePalette(corePalette);

final _colorSchemeDark = Material3ColorScheme.darkOfCorePalette(corePalette);

final List<HctColor> customHctColors = [
  HctColor.fromInt(Colors.orange.value),
  HctColor.fromInt(Colors.brown.value),
  HctColor.fromInt(Colors.yellow.value),
  HctColor.fromInt(Colors.yellowAccent.value),
  HctColor.fromInt(Colors.green.value),
  HctColor.fromInt(Colors.lightGreen.value),
  HctColor.fromInt(Colors.red.value),
  HctColor.fromInt(Colors.purple.value)
];

// ignore: constant_identifier_names
const LightThemeName = "Light";

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = getExtraThemeData(
  _colorSchemeLight,
  customHctColors,
);

// ignore: non_constant_identifier_names
ThemeData LightTheme = getThemeData(_colorSchemeLight);

// ignore: constant_identifier_names
const DarkThemeName = "Dark";

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme =
    getExtraThemeData(_colorSchemeDark, customHctColors);

// ignore: non_constant_identifier_names
ThemeData DarkTheme = getThemeData(_colorSchemeDark);
