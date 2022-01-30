import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

final primaryHct = HctColor.fromInt(0xFF0060a7);
final secondaryHct = HctColor.fromInt(0xFF006874);
final tertiaryHct = HctColor.fromInt(0xFF3c691b);
final naturalHct = HctColor.fromInt(0xFF1b1b1b);
final naturalVariantHct = HctColor.fromInt(0xFF1b1b1b);
final errorHct = HctColor.fromInt(0xFFba1b1b);

final primaryTones = TonalPalette.of(primaryHct.hue, primaryHct.chroma);
final secondaryTones = TonalPalette.of(secondaryHct.hue, secondaryHct.chroma);
final tertiaryTones = TonalPalette.of(tertiaryHct.hue, tertiaryHct.chroma);
final naturalTones = TonalPalette.of(naturalHct.hue, naturalHct.chroma);
final naturalVariantTones =
    TonalPalette.of(naturalVariantHct.hue, naturalVariantHct.chroma);
final errorTones = TonalPalette.of(errorHct.hue, errorHct.chroma);

final _colorSchemeLight = Material3ColorScheme.light(
    primaryTones,
    secondaryTones,
    tertiaryTones,
    errorTones,
    naturalTones,
    naturalVariantTones);

final _colorSchemeDark = Material3ColorScheme.dark(primaryTones, secondaryTones,
    tertiaryTones, errorTones, naturalTones, naturalVariantTones);

final orangeHct = HctColor.fromInt(Colors.orange.value);
final yellowHct = HctColor.fromInt(Colors.yellow.value);
final greenHct = HctColor.fromInt(Colors.green.value);
final redHct = HctColor.fromInt(Colors.red.value);
final purpleHct = HctColor.fromInt(Colors.purple.value);

final _custom1Light = CustomColorScheme.light(
    TonalPalette.of(orangeHct.hue, orangeHct.chroma),
    _colorSchemeLight.primary);
final _custom2Light = CustomColorScheme.light(
    TonalPalette.of(yellowHct.hue, yellowHct.chroma),
    _colorSchemeLight.primary);
final _custom3Light = CustomColorScheme.light(
    TonalPalette.of(greenHct.hue, greenHct.chroma), _colorSchemeLight.primary);
final _custom4Light = CustomColorScheme.light(
    TonalPalette.of(redHct.hue, redHct.chroma), _colorSchemeLight.primary);
final _custom5Light = CustomColorScheme.light(
    TonalPalette.of(purpleHct.hue, purpleHct.chroma),
    _colorSchemeLight.primary);

final _custom1Dark = CustomColorScheme.dark(
    TonalPalette.of(orangeHct.hue, orangeHct.chroma), _colorSchemeDark.primary);
final _custom2Dark = CustomColorScheme.dark(
    TonalPalette.of(yellowHct.hue, yellowHct.chroma), _colorSchemeDark.primary);
final _custom3Dark = CustomColorScheme.dark(
    TonalPalette.of(greenHct.hue, greenHct.chroma), _colorSchemeDark.primary);
final _custom4Dark = CustomColorScheme.dark(
    TonalPalette.of(redHct.hue, redHct.chroma), _colorSchemeDark.primary);
final _custom5Dark = CustomColorScheme.dark(
    TonalPalette.of(purpleHct.hue, purpleHct.chroma), _colorSchemeDark.primary);

// ignore: constant_identifier_names
const LightThemeName = "Light";

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = getExtraThemeData(_colorSchemeLight,
    _custom1Light, _custom2Light, _custom3Light, _custom4Light, _custom5Light);

// ignore: non_constant_identifier_names
ThemeData LightTheme = getThemeData(_colorSchemeLight);

// ignore: constant_identifier_names
const DarkThemeName = "Dark";

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = getExtraThemeData(_colorSchemeDark,
    _custom1Dark, _custom2Dark, _custom3Dark, _custom4Dark, _custom5Dark);

// ignore: non_constant_identifier_names
ThemeData DarkTheme = getThemeData(_colorSchemeDark);
