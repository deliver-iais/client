import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

ThemeData DarkTheme =
    ThemeData(brightness: Brightness.dark, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xFF2699FB),
        accentColor: Color(0xFF5F5F5F),
        scaffoldBackgroundColor: Colors.black,
        bottomAppBarColor: Color.fromRGBO(255, 255, 255, 0.2),
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 40),
          headline2: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          headline3: TextStyle(color: Colors.white, fontSize: 20),
          headline4: TextStyle(color: Colors.white, fontSize: 14),
        ),
        appBarTheme: AppBarTheme(color: Colors.black));

ExtraThemeData DarkExtraTheme = ExtraThemeData(
  circleAvatarBackground: Color(0xFF2699FB),
  introColor: Color(0xFF5F5F5F),
  details: Color(0xFF9D9D9D),
  circleAvatarIcon: Colors.white,
  secondColor: Color(0xFF393939),
  active: Colors.white,
  infoChat: Colors.white,
  authText: Color(0xFFBCE0FD),
);
