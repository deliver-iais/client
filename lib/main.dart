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
          Directionality(textDirection: TextDirection.rtl, child: child),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: IntroPage(),
    );
  }
}


