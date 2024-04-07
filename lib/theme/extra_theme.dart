import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/colors.dart' as color;
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class ExtraThemeData {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  final ColorScheme colorScheme;
  final CustomColorScheme primaryColorsScheme;
  final CustomColorScheme secondaryColorsScheme;
  final CustomColorScheme tertiaryColorsScheme;

  Color lowlight() => colorScheme.onPrimary;

  Color highlight() => colorScheme.primary;

  Color surfaceElevation(double number, {bool isSender = false}) => elevation(
        colorScheme.surface,
        isSender ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
        number,
      );

  CustomColorScheme messageColorScheme(Uid uid) {
    if (_authRepo.isCurrentUser(uid)) {
      return primaryColorsScheme;
    }
    return createColorWithString(uid);
  }

  CustomColorScheme createColorWithString(Uid str) {
    final hctColor =
        Hct.fromInt(color.ColorUtils.stringToHexInt(str.asString()));
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

  Color messageBackgroundColor(Uid uid) {
    if (_authRepo.isCurrentUser(uid) || settings.showColorfulMessages.value) {
      return messageColorScheme(uid).primaryContainer;
    } else {
      return colorScheme.surface;
    }
  }

  Color messageForegroundColor(Uid uid) {
    if (_authRepo.isCurrentUser(uid) || settings.showColorfulMessages.value) {
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
