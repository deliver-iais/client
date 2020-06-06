import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

ThemeData darkTheme =
    ThemeData(brightness: Brightness.dark, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xFF2699FB),
        accentColor: Color(0xFF5F5F5F),
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 40),
          headline2: TextStyle(color: Colors.white, fontSize: 30),
          headline3: TextStyle(color: Colors.white, fontSize: 20),
          headline4: TextStyle(color: Colors.white, fontSize: 14),
        ),
        appBarTheme: AppBarTheme(color: Color(0xff1f655d)));

ThemeData lightTheme =
    ThemeData(brightness: Brightness.dark, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xfff5f5f5),
        accentColor: Color(0xff40bf7a),
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 40),
          headline2: TextStyle(color: Colors.white, fontSize: 30),
          headline3: TextStyle(color: Colors.white, fontSize: 20),
          headline4: TextStyle(color: Colors.white, fontSize: 14),
        ),
        appBarTheme: AppBarTheme(
            color: Color(0xff1f655d),
            actionsIconTheme: IconThemeData(color: Colors.white)));

class UxService {
  BehaviorSubject _theme = BehaviorSubject.seeded(darkTheme);

  get themeStream => _theme.stream;

  get theme => _theme.value;

  toggleTheme() {
    if (theme == darkTheme) {
      _theme.add(lightTheme);
    } else {
      _theme.add(darkTheme);
    }
  }
}
