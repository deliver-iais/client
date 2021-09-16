import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

const LightThemeName = "Light";

final primary = Color(0xFF2699FB);
final accent = Colors.grey[800];

final primaryTextTheme = Typography.blackCupertino
    .apply(fontFamily: "Vazir", displayColor: primary, bodyColor: primary);

final accentTextTheme = Typography.blackCupertino
    .apply(fontFamily: "Vazir", displayColor: accent, bodyColor: accent);

final textTheme = Typography.blackCupertino.apply(
    fontFamily: "Vazir", displayColor: Colors.black, bodyColor: Colors.black);

final TextTheme appbarTextTheme =
    textTheme.merge(TextTheme(headline6: TextStyle(fontSize: 24)));

// ignore: non_constant_identifier_names
ThemeData LightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: "Vazir",
  primaryTextTheme: primaryTextTheme,
  accentTextTheme: accentTextTheme,
  textTheme: textTheme,
).copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: primary,
    accentColor: accent,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Color(0xfdf0fff7),
    buttonColor: primary,
    dividerTheme:
        DividerThemeData(space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
    focusColor: Colors.lightBlue[300].withOpacity(0.6),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        textTheme: appbarTextTheme,
        iconTheme: IconThemeData(color: Colors.black)),
    sliderTheme: SliderThemeData(
      thumbColor: primary,
      trackHeight: 2.25,
      activeTrackColor: primary,
      inactiveTrackColor: Colors.white,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    tabBarTheme: TabBarTheme(
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: primary),
          insets: EdgeInsets.zero),
      labelColor: primary,
      unselectedLabelColor: Color(0xbb002121),
    ));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
    centerPageDetails: Color(0xff6a6a6a),
    boxOuterBackground: Colors.white,
    boxBackground: Color(0xFFEFEFF4),
    textDetails: Colors.black,
    menuIconButton: LightTheme.accentColor.withAlpha(50),
    chatOrContactItemDetails: Colors.black,
    sentMessageBox: Color(0xFFDCEDC8),
    receivedMessageBox: Colors.white,
    textMessage: LightTheme.accentColor,
    messageDetails: LightTheme.accentColor.withAlpha(200),
    persistentEventMessage: LightTheme.backgroundColor,
    circularFileStatus: LightTheme.backgroundColor,
    fileMessageDetails: Color(0xff00a394),
    textField: LightTheme.accentColor,
    username: Colors.blue[900],
    seenStatus: Colors.blue,
    inputBoxBackground: Colors.white,
    fileSharingDetails:Colors.black54,
);
