import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/blend/blend.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

class CustomColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const CustomColorScheme(
    this.primary,
    this.onPrimary,
    this.primaryContainer,
    this.onPrimaryContainer,
  );

  Color onPrimaryContainerLowlight() => onPrimaryContainer.withAlpha(150);

  CustomColorScheme.light(TonalPalette tones, Color primary)
      : primary = _harmonizeColor(Color(tones.get(40)), primary),
        onPrimary = _harmonizeColor(Color(tones.get(100)), primary),
        primaryContainer = _harmonizeColor(Color(tones.get(90)), primary),
        onPrimaryContainer = _harmonizeColor(Color(tones.get(10)), primary);

  CustomColorScheme.dark(TonalPalette tones, Color primary)
      : primary = _harmonizeColor(Color(tones.get(80)), primary),
        onPrimary = _harmonizeColor(Color(tones.get(20)), primary),
        primaryContainer = _harmonizeColor(Color(tones.get(30)), primary),
        onPrimaryContainer = _harmonizeColor(Color(tones.get(90)), primary);
}

// Material 3 Design Color Schema
class Material3ColorScheme {
  final Brightness brightness;

  final Color background;
  final Color onBackground;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  final Color outline;

  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  const Material3ColorScheme({
    required this.brightness,
    required this.background,
    required this.onBackground,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.outline,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
  });

  Material3ColorScheme.lightOfCorePalette(CorePalette palette)
      : this.light(
          palette.primary,
          palette.secondary,
          palette.tertiary,
          palette.error,
          palette.neutral,
          palette.neutralVariant,
        );

  Material3ColorScheme.darkOfCorePalette(CorePalette palette)
      : this.dark(
          palette.primary,
          palette.secondary,
          palette.tertiary,
          palette.error,
          palette.neutral,
          palette.neutralVariant,
        );

  Material3ColorScheme.light(
    TonalPalette primaryTones,
    TonalPalette secondaryTones,
    TonalPalette tertiaryTones,
    TonalPalette errorTones,
    TonalPalette neutralTones,
    TonalPalette neutralVariantTones,
  )   : brightness = Brightness.light,
        primary = Color(primaryTones.get(40)),
        onPrimary = Color(primaryTones.get(100)),
        primaryContainer = Color(primaryTones.get(90)),
        onPrimaryContainer = Color(primaryTones.get(10)),
        secondary = Color(secondaryTones.get(40)),
        onSecondary = Color(secondaryTones.get(100)),
        secondaryContainer = Color(secondaryTones.get(90)),
        onSecondaryContainer = Color(secondaryTones.get(10)),
        tertiary = Color(tertiaryTones.get(40)),
        onTertiary = Color(tertiaryTones.get(100)),
        tertiaryContainer = Color(tertiaryTones.get(90)),
        onTertiaryContainer = Color(tertiaryTones.get(10)),
        surface = Color(neutralTones.get(99)),
        onSurface = Color(neutralTones.get(10)),
        surfaceVariant = Color(neutralVariantTones.get(90)),
        onSurfaceVariant = Color(neutralVariantTones.get(30)),
        error = Color(errorTones.get(40)),
        onError = Color(errorTones.get(100)),
        errorContainer = Color(errorTones.get(90)),
        onErrorContainer = Color(errorTones.get(10)),
        outline = Color(neutralVariantTones.get(50)),
        inverseSurface = Color(neutralTones.get(20)),
        onInverseSurface = Color(neutralTones.get(95)),
        inversePrimary = Color(primaryTones.get(80)),
        background = Color(neutralTones.get(99)),
        onBackground = Color(neutralTones.get(10));

  Material3ColorScheme.dark(
    TonalPalette primaryTones,
    TonalPalette secondaryTones,
    TonalPalette tertiaryTones,
    TonalPalette errorTones,
    TonalPalette naturalTones,
    TonalPalette naturalVariantTones,
  )   : brightness = Brightness.dark,
        primary = Color(primaryTones.get(80)),
        onPrimary = Color(primaryTones.get(20)),
        primaryContainer = Color(primaryTones.get(30)),
        onPrimaryContainer = Color(primaryTones.get(90)),
        secondary = Color(secondaryTones.get(80)),
        onSecondary = Color(secondaryTones.get(20)),
        secondaryContainer = Color(secondaryTones.get(30)),
        onSecondaryContainer = Color(secondaryTones.get(90)),
        tertiary = Color(tertiaryTones.get(80)),
        onTertiary = Color(tertiaryTones.get(20)),
        tertiaryContainer = Color(tertiaryTones.get(30)),
        onTertiaryContainer = Color(tertiaryTones.get(90)),
        surface = Color(naturalTones.get(10)),
        onSurface = Color(naturalTones.get(90)),
        surfaceVariant = Color(naturalVariantTones.get(30)),
        onSurfaceVariant = Color(naturalVariantTones.get(80)),
        error = Color(errorTones.get(80)),
        onError = Color(errorTones.get(20)),
        errorContainer = Color(errorTones.get(30)),
        onErrorContainer = Color(errorTones.get(90)),
        outline = Color(naturalVariantTones.get(60)),
        inverseSurface = Color(naturalTones.get(90)),
        onInverseSurface = Color(naturalTones.get(20)),
        inversePrimary = Color(primaryTones.get(40)),
        background = Color(naturalTones.get(10)),
        onBackground = Color(naturalTones.get(90));
}

Color _harmonizeColor(Color from, Color to) {
  if (from == to) return from;
  return Color(Blend.harmonize(from.value, to.value));
}

Color elevation(Color surface, Color primary, int number) =>
    Color.lerp(surface, primary, number * 3 / 100)!;

ColorScheme getColorScheme(Material3ColorScheme colorScheme) {
  return ColorScheme(
    primary: colorScheme.primary,
    onPrimary: colorScheme.onPrimary,
    primaryContainer: colorScheme.primaryContainer,
    onPrimaryContainer: colorScheme.onPrimaryContainer,
    secondary: colorScheme.secondary,
    onSecondary: colorScheme.onSecondary,
    secondaryContainer: colorScheme.secondaryContainer,
    onSecondaryContainer: colorScheme.onSecondaryContainer,
    tertiary: colorScheme.tertiary,
    onTertiary: colorScheme.onTertiary,
    tertiaryContainer: colorScheme.tertiaryContainer,
    onTertiaryContainer: colorScheme.onTertiaryContainer,
    surface: colorScheme.surface,
    onSurface: colorScheme.onSurface,
    surfaceVariant: colorScheme.surfaceVariant,
    onSurfaceVariant: colorScheme.onSurfaceVariant,
    inversePrimary: colorScheme.inversePrimary,
    inverseSurface: colorScheme.inverseSurface,
    onInverseSurface: colorScheme.onInverseSurface,
    background: colorScheme.background,
    onBackground: colorScheme.onBackground,
    error: colorScheme.error,
    onError: colorScheme.onError,
    errorContainer: colorScheme.errorContainer,
    onErrorContainer: colorScheme.onErrorContainer,
    outline: colorScheme.outline,
    brightness: colorScheme.brightness,
  );
}

ThemeData getThemeData(Material3ColorScheme colorScheme) {
  final primaryTextTheme = GoogleFonts.vazirmatnTextTheme(
    Typography.blackCupertino.apply(
      displayColor: colorScheme.primary,
      bodyColor: colorScheme.primary,
    ),
  );

  final textTheme = GoogleFonts.vazirmatnTextTheme(
    Typography.blackCupertino.apply(
      displayColor: colorScheme.onBackground,
      bodyColor: colorScheme.onBackground,
    ),
  );

  final theme = ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    fontFamily: GoogleFonts.vazirmatn().fontFamily,
    primaryColor: colorScheme.primary,
    colorScheme: getColorScheme(colorScheme),
    scaffoldBackgroundColor:
        elevation(colorScheme.surface, colorScheme.primary, 2),
    primaryTextTheme: primaryTextTheme,
    textTheme: textTheme,
    cardColor: colorScheme.surface,
    backgroundColor: colorScheme.background,
    highlightColor: colorScheme.primary,
    focusColor: colorScheme.primary.withAlpha(50),
  );

  return theme.copyWith(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      actionTextColor: colorScheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: secondaryBorder),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 10,
      textStyle: TextStyle(color: colorScheme.primary, fontSize: 14),
      shape: const RoundedRectangleBorder(borderRadius: secondaryBorder),
      color: colorScheme.surface,
    ),
    dividerTheme: const DividerThemeData(space: 1.0, thickness: 1.0),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: secondaryBorder),
    ),
    appBarTheme: AppBarTheme(
      color: colorScheme.surface.withOpacity(0.7),
      elevation: 1,
      scrolledUnderElevation: 4,
      titleTextStyle: textTheme.headline5,
      toolbarTextStyle: textTheme.headline6,
      iconTheme: IconThemeData(color: colorScheme.primary),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: colorScheme.primary,
      trackHeight: 2.25,
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surface,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    chipTheme: theme.chipTheme.copyWith(
      backgroundColor: colorScheme.surface,
      labelStyle:
          theme.chipTheme.labelStyle?.copyWith(color: colorScheme.onSurface),
      shape: const RoundedRectangleBorder(borderRadius: tertiaryBorder),
      side: BorderSide(color: colorScheme.outline),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
        side: BorderSide(color: colorScheme.outline),
      ),
    ),
  );
}

ExtraThemeData getExtraThemeData(Material3ColorScheme colorScheme) =>
    ExtraThemeData(colorScheme: colorScheme);
