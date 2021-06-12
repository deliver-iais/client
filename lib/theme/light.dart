import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
ThemeData LightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Vazir")
    .copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // primaryColor: Color(0xFF2699FB),
    // accentColor: Color(0x8bc1e0FF),
    primaryColor:Color(0xff179c96),
    accentColor: Color(0xff002121),
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Color(0xfde2f8f0),
    buttonColor: Color(0xff1f655d),
    focusColor: Color(0xFF2699FB).withOpacity(0.5),
    cardColor: Color(0xff489088),
    textTheme: TextTheme(
      headline1: TextStyle(color: Colors.white, fontSize: 40),
      headline2: TextStyle(
          color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      headline3: TextStyle(color: Colors.white, fontSize: 20),
      headline4: TextStyle(color: Colors.white, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      color: Color(0xff1f655d),
      elevation: 0,

    ),
    tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.blue),
            insets: EdgeInsets.zero),
        labelColor: Color(0xFF2699FB),
        unselectedLabelColor: Colors.white));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
  circleAvatarBackground: Color(0xFF2699FB),
  details: Color(0xff0b796c),
  circleAvatarIcon: Colors.white,
  secondColor: Colors.white,
  active: Color(0xff174b45),
  infoChat: Colors.black,
  text: Colors.white,
  boxDetails: Color(0xff15786c),
  boxBackground: Color(0xfde2f8f0),
  activeKey: Color(0xff15786c),

  textDetails : Color(0xff4bd5af),
  //homePage
    bottomNavigationAppbar : LightTheme.appBarTheme.color.withAlpha(200),
    activePageIcon: LightTheme.backgroundColor,
    inactivePageIcon : LightTheme.accentColor.withAlpha(100), //details in extra
    menuIconButton : LightTheme.accentColor.withAlpha(50),
    popupMenuButton : LightTheme.backgroundColor.withOpacity(0.8),
    popupMenuButtonDetails : LightTheme.accentColor,
    searchBox: LightTheme.appBarTheme.color.withAlpha(50),
    displayName : Colors.black,//info chat in extra
    // roomPage
    sentMessageBox:  Color(0xff00a394),
    receivedMessageBox: Color(0xff00805a).withAlpha(50),
    textMessage: Colors.black,
    messageDetails: LightTheme.accentColor.withAlpha(200),
    persistentEventMessage: LightTheme.backgroundColor,
   // dark = DarkTheme.accentColor.withAlpha(50), ligh = background
  //dark = blue light = boxdetails

);