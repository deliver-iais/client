import 'package:flutter/material.dart';
import './screen/app-intro/pages/intro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.ltr, child: child),
      theme: ThemeData(
        primaryColor: Color(0xFF2699FB),
        accentColor: Color(0xFF5F5F5F),
        backgroundColor: Colors.black,
        fontFamily: "Vazir",
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 40),
          headline2: TextStyle(color: Colors.white, fontSize: 30),
          headline3: TextStyle(color: Colors.white, fontSize: 20),
          headline4: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      home: IntroPage(),
    );
  }
}
