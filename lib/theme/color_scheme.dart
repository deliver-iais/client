import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

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
}

Color lowlight(bool isSender, BuildContext context) {
  return !isSender
      ? ExtraTheme.of(context).colorScheme.onPrimary
      : ExtraTheme.of(context).colorScheme.onTertiary;
}

Color highlight(bool isSender, BuildContext context) {
  return !isSender
      ? ExtraTheme.of(context).colorScheme.primary
      : ExtraTheme.of(context).colorScheme.tertiary;
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
              elevation(colorScheme.surface, colorScheme.primary, 2),
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
              color: elevation(colorScheme.surface, colorScheme.primary, 5),
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

ExtraThemeData getExtraThemeData(Material3ColorScheme colorScheme) {
  return ExtraThemeData(
      onDetailsBox: colorScheme.onPrimaryContainer, colorScheme: colorScheme);
}
