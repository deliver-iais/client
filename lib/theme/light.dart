import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

ThemeData LightTheme =
    ThemeData(brightness: Brightness.dark, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xfff5f5f5),
        accentColor: Color(0xff40bf7a),
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.black,
        textTheme: TextTheme(
            headline1: TextStyle(color: Colors.white, fontSize: 40),
            headline2: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
            headline3: TextStyle(color: Colors.white, fontSize: 20),
            headline4: TextStyle(color: Colors.white, fontSize: 14),
            bodyText2: TextStyle(color: Colors.black)),
        appBarTheme: AppBarTheme(
            color: Color(0xff1f655d),
            actionsIconTheme: IconThemeData(color: Colors.white)),
        tabBarTheme: TabBarTheme(
          labelColor: Color(0xFF2699FB),
          unselectedLabelColor: Color(0xFF9D9D9D),
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: Colors.blue),
              insets: EdgeInsets.zero),
        ),
        iconTheme: IconThemeData(color:Colors.grey )
       );

ExtraThemeData LightExtraTheme = ExtraThemeData(
  circleAvatarBackground: Color(0xFF5F5F5F),
  details: Color(0xFF9D9D9D),
  circleAvatarIcon: Colors.white,
  secondColor: Color(0xFF393939),
  active: Colors.white,
  infoChat: Colors.white,
  text: Color(0xFFBCE0FD),
);
