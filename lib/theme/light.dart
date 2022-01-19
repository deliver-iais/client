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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: Color(0xfdf0fff7)),
    dividerTheme: const DividerThemeData(
        space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
    focusColor: Colors.lightBlue[300]!.withOpacity(0.6),
    cardColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
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
    tabBarTheme: const TabBarTheme(
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: primary),
          insets: EdgeInsets.zero),
      labelColor: primary,
      unselectedLabelColor: Color(0xbb002121),
    ));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
  centerPageDetails: const Color(0xff6a6a6a),
  boxOuterBackground: Colors.white,
  boxBackground: const Color(0xFFEFEFF4),
  menuIconButton: secondary!.withAlpha(50),
  chatOrContactItemDetails: Colors.black,
  sentMessageBoxBackground: const Color(0xffeffdde),
  defaultBackground: Colors.white,
  highlightOnSentMessage: const Color(0xff57b84c),
  highlight: LightTheme.primaryColor,
  lowlightOnSentMessage: const Color(0xff57b84c).withAlpha(10),
  lowlight: LightTheme.primaryColor.withAlpha(10),
  circularFileStatus: LightTheme.backgroundColor,
  fileMessageDetails: const Color(0xff00a394),
  seenStatus: Colors.blue,
  inputBoxBackground: Colors.white,
  fileSharingDetails: Colors.black54,
  onDetailsBox: Colors.white,
);
