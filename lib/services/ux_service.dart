import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: Color(0xff1f655d),
    accentColor: Color(0xff40bf7a),
    appBarTheme: AppBarTheme(color: Color(0xff1f655d)));

ThemeData lightTheme = ThemeData.light().copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: Color(0xfff5f5f5),
    accentColor: Color(0xff40bf7a),
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
