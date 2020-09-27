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
            labelColor: Color(0xFF2699FB), unselectedLabelColor: Colors.white));

ExtraThemeData DarkExtraTheme = ExtraThemeData(
  circleAvatarBackground: Color(0xFF2699FB),
  details: Color(0xFF9D9D9D),
  circleAvatarIcon: Colors.white,
  secondColor: Color(0xFF393939),
  active: Colors.white,
  infoChat: Colors.white,
  text: Color(0xFFBCE0FD),
);
