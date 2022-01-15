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
    dividerTheme: const DividerThemeData(
        space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
    focusColor: Colors.lightBlue[300]!.withOpacity(0.6),
    cardColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
      ),
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
  textDetails: Colors.black,
  menuIconButton: secondary!.withAlpha(50),
  chatOrContactItemDetails: Colors.black,
  sentMessageBox: const Color(0xffdcf8c6),
  sentMessageBoxForeground: const Color(0xff376b04),
  receivedMessageBox: Colors.white,
  textMessage: secondary!,
  messageDetails: secondary!.withAlpha(200),
  persistentEventMessage: LightTheme.backgroundColor,
  circularFileStatus: LightTheme.backgroundColor,
  fileMessageDetails: const Color(0xff00a394),
  textField: secondary!,
  username: Colors.blue[900]!,
  seenStatus: Colors.blue,
  inputBoxBackground: Colors.white,
  fileSharingDetails: Colors.black54,
);
