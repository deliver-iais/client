import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/blend/blend.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

class CustomColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const CustomColorScheme(this.primary, this.onPrimary, this.primaryContainer,
      this.onPrimaryContainer);

  Color onPrimaryContainerVariant() => onPrimaryContainer.withAlpha(150);

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
  final Color primaryInverse;

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
    required this.primaryInverse,
  });

  Material3ColorScheme.light(
      TonalPalette primaryTones,
      TonalPalette secondaryTones,
      TonalPalette tertiaryTones,
      TonalPalette errorTones,
      TonalPalette naturalTones,
      TonalPalette naturalVariantTones)
      : brightness = Brightness.light,
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
        surface = Color(naturalTones.get(99)),
        onSurface = Color(naturalTones.get(10)),
        surfaceVariant = Color(naturalVariantTones.get(90)),
        onSurfaceVariant = Color(naturalVariantTones.get(30)),
        error = Color(errorTones.get(40)),
        onError = Color(errorTones.get(100)),
        errorContainer = Color(errorTones.get(90)),
        onErrorContainer = Color(errorTones.get(10)),
        outline = Color(naturalVariantTones.get(50)),
        inverseSurface = Color(naturalTones.get(20)),
        onInverseSurface = Color(naturalTones.get(95)),
        primaryInverse = Color(primaryTones.get(80)),
        background = Color(naturalTones.get(99)),
        onBackground = Color(naturalTones.get(10));

  Material3ColorScheme.dark(
      TonalPalette primaryTones,
      TonalPalette secondaryTones,
      TonalPalette tertiaryTones,
      TonalPalette errorTones,
      TonalPalette naturalTones,
      TonalPalette naturalVariantTones)
      : brightness = Brightness.dark,
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
        primaryInverse = Color(primaryTones.get(40)),
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
      primaryVariant: colorScheme.primaryContainer,
      secondary: colorScheme.secondary,
      secondaryVariant: colorScheme.secondaryContainer,
      surface: colorScheme.surface,
      background: colorScheme.background,
      error: colorScheme.error,
      onPrimary: colorScheme.onPrimary,
      onSecondary: colorScheme.onSecondary,
      onSurface: colorScheme.onSurface,
      onBackground: colorScheme.onBackground,
      onError: colorScheme.onError,
      brightness: colorScheme.brightness);
}

ThemeData getThemeData(Material3ColorScheme colorScheme) {
  final primaryTextTheme = Typography.blackCupertino.apply(
      fontFamily: "Vazir",
      displayColor: colorScheme.primary,
      bodyColor: colorScheme.primary);

  final textTheme = Typography.blackCupertino.apply(
      fontFamily: "Vazir",
      displayColor: colorScheme.onBackground,
      bodyColor: colorScheme.onBackground);

  return ThemeData(
          brightness: colorScheme.brightness,
          fontFamily: "Vazir",
          primaryColor: colorScheme.primary,
          colorScheme: getColorScheme(colorScheme),
          scaffoldBackgroundColor:
              elevation(colorScheme.surface, colorScheme.secondary, 1),
          primaryTextTheme: primaryTextTheme,
          textTheme: textTheme,
          cardColor: colorScheme.surface,
          backgroundColor: colorScheme.background,
          highlightColor: colorScheme.primary,
          focusColor: colorScheme.primary.withAlpha(50))
      .copyWith(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          snackBarTheme: SnackBarThemeData(
              backgroundColor: colorScheme.inverseSurface,
              actionTextColor: colorScheme.primaryInverse,
              shape:
                  const RoundedRectangleBorder(borderRadius: secondaryBorder)),
          popupMenuTheme: PopupMenuThemeData(
              textStyle: TextStyle(color: colorScheme.primary, fontSize: 14),
              shape:
                  const RoundedRectangleBorder(borderRadius: secondaryBorder),
              color: colorScheme.surface),
          dividerTheme: const DividerThemeData(space: 1.0, thickness: 1.0),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: secondaryBorder),
          ),
          appBarTheme: AppBarTheme(
              color: colorScheme.surface,
              elevation: 0,
              titleTextStyle: textTheme.headline5,
              toolbarTextStyle: textTheme.headline6,
              iconTheme: IconThemeData(color: colorScheme.primary)),
          sliderTheme: SliderThemeData(
            thumbColor: colorScheme.primary,
            trackHeight: 2.25,
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surface,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
            side: BorderSide(width: 1.0, color: colorScheme.outline),
          )),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
          )),
          dialogTheme: const DialogTheme(
              shape: RoundedRectangleBorder(borderRadius: mainBorder)),
          tabBarTheme: TabBarTheme(
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: colorScheme.primary),
                insets: EdgeInsets.zero),
            labelColor: colorScheme.primary,
          ));
}

ExtraThemeData getExtraThemeData(
    Material3ColorScheme colorScheme,
    CustomColorScheme custom1,
    CustomColorScheme custom2,
    CustomColorScheme custom3,
    CustomColorScheme custom4,
    CustomColorScheme custom5) {
  return ExtraThemeData(
    onDetailsBox: colorScheme.onPrimaryContainer,
    colorScheme: colorScheme,
    custom1: custom1,
    custom2: custom2,
    custom3: custom3,
    custom4: custom4,
    custom5: custom5,
  );
}
