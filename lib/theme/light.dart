import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

const LightThemeName = "Light";

const primary = Color(0xFF2699FB);
const accent = Color(0xff002121);

// ignore: non_constant_identifier_names
ThemeData LightTheme =
    ThemeData(brightness: Brightness.light, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: primary,
        accentColor: accent,
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Color(0xfde2f8f0),
        buttonColor: primary,
        dividerTheme: DividerThemeData(
            space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
        focusColor: Colors.lightBlue[300].withOpacity(0.6),
        cardColor: Colors.white,
        popupMenuTheme: PopupMenuThemeData(
            textStyle: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'Vazir')),
        primaryTextTheme: TextTheme(
          headline1: TextStyle(color: Colors.black, fontSize: 40),
          headline2: TextStyle(color: Colors.black, fontSize: 25),
          headline3: TextStyle(color: Colors.black, fontSize: 20),
          headline4: TextStyle(color: Colors.black, fontSize: 18),
          headline6: TextStyle(color: Colors.black, fontSize: 15),
          bodyText1: TextStyle(color: Colors.black, fontSize: 15),
          bodyText2: TextStyle(color: Colors.black, fontSize: 14),
        ).apply(fontFamily: "Vazir", displayColor: primary, bodyColor: primary),
        accentTextTheme: TextTheme(
          headline1: TextStyle(color: Colors.black, fontSize: 40),
          headline2: TextStyle(color: Colors.black, fontSize: 25),
          headline3: TextStyle(color: Colors.black, fontSize: 20),
          headline4: TextStyle(color: Colors.black, fontSize: 18),
          headline6: TextStyle(color: Colors.black, fontSize: 15),
          bodyText1: TextStyle(color: Colors.black, fontSize: 15),
          bodyText2: TextStyle(color: Colors.black, fontSize: 14),
        ).apply(fontFamily: "Vazir", displayColor: accent, bodyColor: accent),
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.black, fontSize: 40),
          headline2: TextStyle(color: Colors.black, fontSize: 25),
          headline3: TextStyle(color: Colors.black, fontSize: 20),
          headline4: TextStyle(color: Colors.black, fontSize: 18),
          headline6: TextStyle(color: Colors.black, fontSize: 15),
          bodyText1: TextStyle(color: Colors.black, fontSize: 15),
          bodyText2: TextStyle(color: Colors.black, fontSize: 14),
        ).apply(
            fontFamily: "Vazir",
            displayColor: Colors.black,
            bodyColor: Colors.black),
        dialogTheme: DialogTheme(
            titleTextStyle:
                TextStyle(color: Colors.black, fontSize: 18, inherit: true)),
        appBarTheme: AppBarTheme(
            color: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: accent)),
        sliderTheme: SliderThemeData(
          thumbColor: primary,
          trackHeight: 2.25,
          activeTrackColor: primary,
          inactiveTrackColor: Colors.white,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
        ),
        iconTheme: IconThemeData(color: accent),
        tabBarTheme: TabBarTheme(
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: primary),
              insets: EdgeInsets.zero),
          labelColor: primary,
          unselectedLabelColor: Color(0xbb002121),
        ));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
  centerPageDetails: Color(0xff0b796c),
  circleAvatarIcon: primary,
  boxDetails: Color(0xff15786c),
  boxOuterBackground: Colors.white,
  boxBackground: Color(0xFFEFEFF4),
  textDetails: Colors.black,
  menuIconButton: LightTheme.accentColor.withAlpha(50),
  popupMenuButton: Colors.white,
  popupMenuButtonDetails: LightTheme.accentColor,
  searchBox: Color(0xFFEEEEEE),
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
  titleStatus: Colors.blue,
  seenStatus: Colors.blue,
  inputBoxBackground: Colors.white,
  mentionAutoCompleter: Colors.white,
  border: Color(0xff174b45),
);
