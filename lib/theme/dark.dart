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
    bottomAppBarColor: const Color.fromRGBO(255, 255, 255, 0.2),
    backgroundColor: const Color(0xFF00101A),
    dividerTheme: const DividerThemeData(
        space: 1.0, thickness: 1.0, color: Color(0xff313131)),
    focusColor: primary.withOpacity(0.5),
    cardColor: primary,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    appBarTheme: AppBarTheme(
        color: const Color(0xFF03151d),
        elevation: 0,
        titleTextStyle: textTheme.headline5,
        toolbarTextStyle: textTheme.headline6),
    popupMenuTheme: const PopupMenuThemeData(
        textStyle: TextStyle(color: primary, fontSize: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: Color(0xFF032738)),
    sliderTheme: const SliderThemeData(
      thumbColor: Colors.white,
      trackHeight: 2.25,
      activeTrackColor: Colors.white,
      inactiveTrackColor: Color(0xFFBCE0FD),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    tabBarTheme: const TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.blue),
            insets: EdgeInsets.zero),
        labelColor: primary,
        unselectedLabelColor: Colors.white));

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = ExtraThemeData(
  centerPageDetails: const Color(0xFF9D9D9D),
  boxOuterBackground: const Color(0xFF03151d),
  boxBackground: const Color(0xFF032738),
  menuIconButton: secondary.withAlpha(50),
  chatOrContactItemDetails: Colors.white,
  //info chat in extra
  sentMessageBoxBackground: const Color(0xFF0674A1),
  highlightOnSentMessage: primary,
  defaultBackground: const Color(0xFF182731),
  highlight: primary,
  lowlightOnSentMessage: const Color(0xFF043549),
  lowlight: const Color(0xFF03151d),
  circularFileStatus: const Color(0xFFBCE0FD),
  fileMessageDetails: DarkTheme.primaryColor,
  seenStatus: Colors.white,
  fileSharingDetails: Colors.white54,
  inputBoxBackground: secondary,
  onDetailsBox: Colors.white,
);
