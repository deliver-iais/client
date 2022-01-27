import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const DarkThemeName = "Dark";

const primary = Color(0xFF2699FB);
const secondary = Color(0xFF182731);

final primaryTextTheme = Typography.whiteCupertino
    .apply(fontFamily: "Vazir", displayColor: primary, bodyColor: primary);

final textTheme = Typography.whiteCupertino.apply(
    fontFamily: "Vazir", displayColor: Colors.white, bodyColor: Colors.white);

// ignore: non_constant_identifier_names
ThemeData DarkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Vazir",
  primaryTextTheme: primaryTextTheme,
  textTheme: textTheme,
).copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF021a25),
    colorScheme:
        const ColorScheme.dark(primary: primary, surface: Color(0xFF182731)),
    bottomAppBarColor: const Color.fromRGBO(255, 255, 255, 0.2),
    backgroundColor: const Color(0xFF00101A),
    dividerTheme: const DividerThemeData(
        space: 1.0, thickness: 1.0, color: Color(0xff313131)),
    focusColor: primary.withOpacity(0.5),
    cardColor: primary,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: secondaryBorder),
    ),
    appBarTheme: AppBarTheme(
        color: const Color(0xFF03151d),
        elevation: 0,
        titleTextStyle: textTheme.headline5,
        toolbarTextStyle: textTheme.headline6),
    popupMenuTheme: const PopupMenuThemeData(
        textStyle: TextStyle(color: primary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: secondaryBorder),
        color: Color(0xFF1E303B)),
    sliderTheme: const SliderThemeData(
      thumbColor: Colors.white,
      trackHeight: 2.25,
      activeTrackColor: Colors.white,
      inactiveTrackColor: Color(0xFFBCE0FD),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
          side: const BorderSide(width: 1.0, color: Color(0xB3175B93)),
        )),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
        )),
    dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: mainBorder)),
    tabBarTheme: const TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.blue),
            insets: EdgeInsets.zero),
        labelColor: primary,
        unselectedLabelColor: Colors.white));

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = ExtraThemeData(
  chatOrContactItemDetails: Colors.white,
  sentMessageBoxBackground: const Color(0xFF0674A1),
  highlightOnSentMessage: primary,
  highlight: primary,
  onHighlightOnSentMessage: Colors.white,
  onHighlight: Colors.white,
  lowlightOnSentMessage: const Color(0xFF064F6C),
  lowlight: const Color(0xFF1E303B),
  onDetailsBox: Colors.white,
);
