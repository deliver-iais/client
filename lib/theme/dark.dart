import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

const DarkThemeName = "Dark";

final primary = Color(0xFF2699FB);
final accent = Color(0x8bc1e0FF);

final primaryTextTheme = Typography.whiteCupertino
    .apply(fontFamily: "Vazir", displayColor: primary, bodyColor: primary);

final accentTextTheme = Typography.whiteCupertino
    .apply(fontFamily: "Vazir", displayColor: accent, bodyColor: accent);

final textTheme = Typography.whiteCupertino.apply(
    fontFamily: "Vazir", displayColor: Colors.white, bodyColor: Colors.white);

final TextTheme appbarTextTheme =
    textTheme.merge(TextTheme(headline6: TextStyle(fontSize: 24)));

// ignore: non_constant_identifier_names
ThemeData DarkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Vazir",
  primaryTextTheme: primaryTextTheme,
  accentTextTheme: accentTextTheme,
  textTheme: textTheme,
).copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: primary,
    accentColor: accent,
    scaffoldBackgroundColor: Color(0xFF021a25),
    bottomAppBarColor: Color.fromRGBO(255, 255, 255, 0.2),
    backgroundColor: Color(0xFF032738),
    buttonColor: primary,
    dividerTheme:
        DividerThemeData(space: 1.0, thickness: 1.0, color: Color(0xFF3b3b3b)),
    focusColor: primary.withOpacity(0.5),
    cardColor: primary,
    appBarTheme: AppBarTheme(
        color: Color(0xFF03151d), elevation: 0, textTheme: appbarTextTheme),
    popupMenuTheme: PopupMenuThemeData(color: Color(0xFF032738)),
    sliderTheme: SliderThemeData(
      thumbColor: Colors.white,
      trackHeight: 2.25,
      activeTrackColor: Colors.white,
      inactiveTrackColor: Color(0xFFBCE0FD),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.blue),
            insets: EdgeInsets.zero),
        labelColor: primary,
        unselectedLabelColor: Colors.white));

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = ExtraThemeData(
    centerPageDetails: Color(0xFF9D9D9D),
    boxOuterBackground: Color(0xFF03151d),
    boxBackground: Color(0xFF032738),
    textDetails: DarkTheme.primaryColor,
    menuIconButton: DarkTheme.accentColor.withAlpha(50),
    chatOrContactItemDetails: Colors.white,
    //info chat in extra
    sentMessageBox: DarkTheme.primaryColor,
    receivedMessageBox: DarkTheme.accentColor.withAlpha(60),
    textMessage: Colors.white,
    messageDetails: Color(0xFF001D39),
    persistentEventMessage: DarkTheme.accentColor.withAlpha(50),
    circularFileStatus: Color(0xFFBCE0FD),
    fileMessageDetails: DarkTheme.primaryColor,
    textField: Colors.white,
    username: Colors.yellowAccent,
    seenStatus: Colors.white,
    inputBoxBackground: DarkTheme.accentColor.withAlpha(50),
    mentionAutoCompleter: Color(0xFF263238));
