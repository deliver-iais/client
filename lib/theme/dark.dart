import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
ThemeData DarkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Vazir")
    .copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: Color(0xFF2699FB),
    accentColor: Color(0x8bc1e0FF),
    scaffoldBackgroundColor: Colors.black,
    bottomAppBarColor: Color.fromRGBO(255, 255, 255, 0.2),
    backgroundColor: Colors.black,
    buttonColor: Color(0xFF2699FB),
    focusColor: Color(0xFF2699FB).withOpacity(0.5),
    textTheme: TextTheme(
      headline1: TextStyle(color: Colors.white, fontSize: 40),
      headline2: TextStyle(
          color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      headline3: TextStyle(color: Colors.white, fontSize: 20),
      headline4: TextStyle(color: Colors.white, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.black,
      elevation: 0,
    ),
    tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.blue),
            insets: EdgeInsets.zero),
        labelColor: Color(0xFF2699FB),
        unselectedLabelColor: Colors.white));

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = ExtraThemeData(
    circleAvatarBackground: Color(0xFF2699FB),
    details: Color(0xFF9D9D9D),
    circleAvatarIcon: Colors.white,
    secondColor: Color(0xFF393939),
    active: Colors.white,
    infoChat: Colors.white,
    text: Color(0xFFBCE0FD),
    boxDetails: Colors.white,
    boxBackground: Color(0x8bc1e0FF).withAlpha(50),
    activeKey: Color(0xFF2699FB),
    //homePage
    textDetails : DarkTheme.primaryColor,
    bottomNavigationAppbar : DarkTheme.appBarTheme.color.withAlpha(200),
    activePageIcon : Colors.white,//active in extra
    inactivePageIcon : Color(0xFF9D9D9D),//details in extra
    menuIconButton : DarkTheme.accentColor.withAlpha(50),
    popupMenuButton : DarkTheme.accentColor.withAlpha(80),
    popupMenuButtonDetails : Colors.white,
    searchBox: DarkTheme.accentColor.withAlpha(50),
    displayName : Colors.white,//info chat in extra
    sentMessageBox: DarkTheme.primaryColor,
    receivedMessageBox: DarkTheme.accentColor.withAlpha(60),
    textMessage: Colors.white,
    messageDetails: Color(0xFFB3B3B3),
);