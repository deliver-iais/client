import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const LightThemeName = "Light";

const primary = Color(0xFF2699FB);
final secondary = Colors.grey[800];

final primaryTextTheme = Typography.blackCupertino
    .apply(fontFamily: "Vazir", displayColor: primary, bodyColor: primary);

final textTheme = Typography.blackCupertino.apply(
    fontFamily: "Vazir", displayColor: Colors.black, bodyColor: Colors.black);

// ignore: non_constant_identifier_names
ThemeData LightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: "Vazir",
  primaryTextTheme: primaryTextTheme,
  textTheme: textTheme,
).copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: const Color(0xfdf0fff7),
    popupMenuTheme: const PopupMenuThemeData(
        textStyle: TextStyle(color: primary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: secondaryBorder),
        color: Color(0xffeef7ff)),
    dividerTheme: const DividerThemeData(
        space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
    focusColor: Colors.lightBlue[300]!.withOpacity(0.6),
    cardColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: secondaryBorder),
    ),
    appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        titleTextStyle: textTheme.headline5,
        toolbarTextStyle: textTheme.headline6,
        iconTheme: const IconThemeData(color: Colors.black)),
    sliderTheme: const SliderThemeData(
      thumbColor: primary,
      trackHeight: 2.25,
      activeTrackColor: primary,
      inactiveTrackColor: Colors.white,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
        )),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: buttonBorder),
        )),
    dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: mainBorder)),
    tabBarTheme: const TabBarTheme(
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: primary),
          insets: EdgeInsets.zero),
      labelColor: primary,
      unselectedLabelColor: Color(0xbb002121),
    ));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
  chatOrContactItemDetails: Colors.black,
  sentMessageBoxBackground: const Color(0xffeffdde),
  highlightOnSentMessage: const Color(0xff57b84c),
  highlight: LightTheme.primaryColor,
  onHighlightOnSentMessage: Colors.white,
  onHighlight: Colors.white,
  lowlightOnSentMessage: Colors.white,
  lowlight: const Color(0xffeef7ff),
  onDetailsBox: Colors.white,
);
