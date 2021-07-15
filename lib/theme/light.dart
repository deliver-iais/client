import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

const LightThemeName = "Light";

// ignore: non_constant_identifier_names
ThemeData LightTheme =
    ThemeData(brightness: Brightness.light, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // primaryColor: Color(0xFF2699FB),
        // accentColor: Color(0x8bc1e0FF),
        primaryColor: Color(0xff179c96),
        accentColor: Color(0xff002121),
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Color(0xfde2f8f0),
        buttonColor: Color(0xff1f655d),
        dividerTheme: DividerThemeData(
            space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
        focusColor: Color(0xff179c96).withOpacity(0.4),
        cardColor: Color(0xff489088),
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.black, fontSize: 40),
          headline2: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          headline3: TextStyle(color: Colors.black, fontSize: 20),
          headline4: TextStyle(color: Colors.black, fontSize: 18),
          headline6: TextStyle(color: Colors.black, fontSize: 15),
          bodyText2: TextStyle(color: Colors.black, fontSize: 15),
        ),
        dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 18)),
        appBarTheme: AppBarTheme(
            color: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xff002121))),
        sliderTheme: SliderThemeData(
          thumbColor: Color(0xff4bd5af),
          trackHeight: 2.25,
          activeTrackColor: Color(0xff4bd5af),
          inactiveTrackColor: Color(0xff179c96),
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
        ),
        iconTheme: IconThemeData(color: Color(0xff002121)),
        tabBarTheme: TabBarTheme(
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: Colors.blue),
              insets: EdgeInsets.zero),
          labelColor: Color(0xff179c96),
          unselectedLabelColor: Color(0xff002121),
        ));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
  centerPageDetails: Color(0xff0b796c),
  circleAvatarIcon: Colors.white,
  boxDetails: Color(0xff15786c),
  boxBackground: Color(0xFFf2f9ff),
  activeSwitch: Color(0xff15786c),
  textDetails: Colors.black,
  bottomNavigationAppbar: LightTheme.appBarTheme.color,
  activePageIcon: LightTheme.accentColor,
  inactivePageIcon: LightTheme.accentColor.withAlpha(100),
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
  username: Colors.blue,
  titleStatus: Colors.blue,
  seenStatus: Colors.blue,
  pinMessageTheme: Colors.white,
  inputBoxBackground: Colors.white,
  mentionWidget: Colors.white,
  border: Color(0xff174b45),
);