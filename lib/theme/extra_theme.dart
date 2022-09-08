import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class ExtraThemeData {
  static final _usServices = GetIt.I.get<UxService>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  final Material3ColorScheme colorScheme;
  final CustomColorScheme primaryColorsScheme;
  final CustomColorScheme secondaryColorsScheme;
  final CustomColorScheme tertiaryColorsScheme;

  Color lowlight() => colorScheme.onPrimary;

  Color highlight() => colorScheme.primary;

  Color surfaceElevation(int number, {bool isSender = false}) => elevation(
        colorScheme.surface,
        isSender ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
        number,
      );

  CustomColorScheme messageColorScheme(String uid) {
    if (_authRepo.isCurrentUser(uid)) {
      return primaryColorsScheme;
    }
    return createColorWithString(uid);
  }

  CustomColorScheme createColorWithString(String str) {
    final hctColor = Hct.fromInt(ColorUtils.stringToHexInt(str));

    if (colorScheme.brightness == Brightness.light) {
      return CustomColorScheme.light(
        TonalPalette.of(hctColor.hue, hctColor.chroma),
        Colors.black,
      );
    } else {
      return CustomColorScheme.dark(
        TonalPalette.of(hctColor.hue, hctColor.chroma),
        Colors.white,
      );
    }
  }

  Color messageBackgroundColor(String uid) {
    if (_authRepo.isCurrentUser(uid) || _usServices.showColorful) {
      return messageColorScheme(uid).primaryContainer;
    } else {
      return colorScheme.surface;
    }
  }

  Color messageForegroundColor(String uid) {
    if (_authRepo.isCurrentUser(uid) || _usServices.showColorful) {
      return messageColorScheme(uid).onPrimaryContainerLowlight();
    } else {
      return colorScheme.onSurface;
    }
  }

  ExtraThemeData({
    required this.colorScheme,
  })  : primaryColorsScheme = CustomColorScheme(
          colorScheme.primary,
          colorScheme.onPrimary,
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
        secondaryColorsScheme = CustomColorScheme(
          colorScheme.secondary,
          colorScheme.onSecondary,
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
        tertiaryColorsScheme = CustomColorScheme(
          colorScheme.tertiary,
          colorScheme.onTertiary,
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
        );
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  const ExtraTheme({
    super.key,
    required super.child,
    required this.extraThemeData,
  });

  static ExtraThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ExtraTheme>()!
        .extraThemeData;
  }

  @override
  bool updateShouldNotify(ExtraTheme oldWidget) => false;
}
