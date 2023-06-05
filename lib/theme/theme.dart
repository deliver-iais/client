import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

final ACTIVE_COLOR = Colors.greenAccent.shade700;

TextStyle getFadeTextStyle(BuildContext context) {
  return TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
    fontWeight: FontWeight.w600,
  );
}

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
  "pattern-8",
];

ThemeScheme getThemeScheme(int index) =>
    ThemeScheme(palettes[index % palettes.length]);

class ThemeScheme {
  final ColorScheme _dark;
  final ColorScheme _light;

  ThemeScheme(Color seed)
      : _dark =
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        _light = ColorScheme.fromSeed(seedColor: seed);

  ThemeData theme({bool isDark = false}) =>
      isDark ? getThemeData(_dark) : getThemeData(_light);

  ExtraThemeData extraTheme({bool isDark = false}) =>
      isDark ? getExtraThemeData(_dark) : getExtraThemeData(_light);
}

extension _HexColor on Color {
  String toHex() => '#'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

List<(String, String)> getCorePaletteList(CorePalette p) {
  return [
    ...getTonalPaletteList("primary", p.primary),
    ...getTonalPaletteList("secondary", p.secondary),
    ...getTonalPaletteList("tertiary", p.tertiary),
    ...getTonalPaletteList("neutral", p.neutral),
    ...getTonalPaletteList("neutral-variant", p.neutralVariant),
    ...getTonalPaletteList("error", p.error),
  ];
}

Iterable<(String, String)> getTonalPaletteList(String name, TonalPalette p) {
  return TonalPalette.commonTones
      .map((tone) => ("--we-color-$name-$tone", Color(p.get(tone)).toHex()));
}

List<(String, String)> getThemeDataColorList(ThemeData data) {
  return [
    ("primary", data.colorScheme.primary.toHex()),
    ("primary-container", data.colorScheme.primaryContainer.toHex()),
    ("on-primary", data.colorScheme.onPrimary.toHex()),
    ("on-primary-container", data.colorScheme.onPrimaryContainer.toHex()),
    ("secondary", data.colorScheme.secondary.toHex()),
    ("secondary-container", data.colorScheme.secondaryContainer.toHex()),
    ("on-secondary", data.colorScheme.onSecondary.toHex()),
    ("on-secondary-container", data.colorScheme.onSecondaryContainer.toHex()),
    ("tertiary", data.colorScheme.tertiary.toHex()),
    ("tertiary-container", data.colorScheme.tertiaryContainer.toHex()),
    ("on-tertiary", data.colorScheme.onTertiary.toHex()),
    ("on-tertiary-container", data.colorScheme.onTertiaryContainer.toHex()),
    ("error", data.colorScheme.error.toHex()),
    ("error-container", data.colorScheme.errorContainer.toHex()),
    ("on-error", data.colorScheme.onError.toHex()),
    ("on-error-container", data.colorScheme.onErrorContainer.toHex()),
    ("surface", data.colorScheme.surface.toHex()),
    ("surface-tint", data.colorScheme.surfaceTint.toHex()),
    ("surface-variant", data.colorScheme.surfaceVariant.toHex()),
    ("on-surface", data.colorScheme.onSurface.toHex()),
    ("on-surface-variant", data.colorScheme.onSurfaceVariant.toHex()),
    ("inverse-primary", data.colorScheme.inversePrimary.toHex()),
    ("inverse-surface", data.colorScheme.inverseSurface.toHex()),
    ("on-inverse-surface", data.colorScheme.onInverseSurface.toHex()),
    ("background", data.colorScheme.background.toHex()),
    ("on-background", data.colorScheme.onBackground.toHex()),
  ].map((e) => ("--we-color-${e.$1}", e.$2)).toList();
}

String colorListToCss(List<(String, String)> list) {
  final variables = list.fold("", (previousValue, elm) {
    final (key, color) = elm;
    return "$previousValue$key:$color;\n";
  });

  return ":root {$variables}";
}
