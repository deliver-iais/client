// import 'package:deliver_flutter/theme/extra_colors.dart';
// import 'package:flutter/material.dart';
//
// // ignore: non_constant_identifier_names
// ThemeData LightTheme = ThemeData(
//         brightness: Brightness.dark,
//         fontFamily: "Vazir",
//         platform: TargetPlatform.iOS)
//     .copyWith(
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         primaryColor: Color(0xfff5f5f5),
//         accentColor: Color(0xff40bf7a),
//         scaffoldBackgroundColor: Colors.white,
//         backgroundColor: Colors.white,
//         cardColor: Color(0xFF2699FB),
//         textTheme: TextTheme(
//           headline1: TextStyle(color: Colors.black, fontSize: 40),
//           headline2: TextStyle(
//               color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
//           headline3: TextStyle(color: Colors.black, fontSize: 20),
//           headline4: TextStyle(color: Colors.black, fontSize: 14),
//         ),
//         appBarTheme: AppBarTheme(
//             textTheme: TextTheme(
//               headline1: TextStyle(color: Colors.black, fontSize: 40),
//               headline2: TextStyle(
//                   color: Colors.black,
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold),
//               headline3: TextStyle(color: Colors.black, fontSize: 20),
//               headline4: TextStyle(color: Colors.black, fontSize: 14),
//             ),
//             color: Color(0xff1f655d),
//             actionsIconTheme: IconThemeData(color: Colors.white)),
//         tabBarTheme: TabBarTheme(
//             labelColor: Color(0xFF2699FB),
//             unselectedLabelColor: Color(0xFF9D9D9D),
//             indicator: UnderlineTabIndicator(
//                 borderSide: BorderSide(width: 2.0, color: Colors.blue),
//                 insets: EdgeInsets.zero)),
//         iconTheme: IconThemeData(color: Colors.grey));
//
// // ignore: non_constant_identifier_names
// ExtraThemeData LightExtraTheme = ExtraThemeData(
//   circleAvatarBackground: Color(0xFF5F5F5F),
//   details: Color(0xFF9D9D9D),
//   circleAvatarIcon: Colors.white,
//   secondColor: Color(0xFF393939),
//   active: Colors.white,
//   infoChat: Colors.white,
//   text: Color(0xFFBCE0FD),
// );

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
    bottomAppBarColor: Color.fromRGBO(255, 255, 255, 0.2),
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
);
