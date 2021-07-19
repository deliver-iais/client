import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

const DarkThemeName = "Dark";

// ignore: non_constant_identifier_names
ThemeData DarkTheme =
    ThemeData(brightness: Brightness.dark, fontFamily: "Vazir").copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xFF2699FB),
        accentColor: Color(0x8bc1e0FF),
        scaffoldBackgroundColor: Color(0xFF021a25),
        bottomAppBarColor: Color.fromRGBO(255, 255, 255, 0.2),
        backgroundColor: Color(0xFF032738),
        buttonColor: Color(0xFF2699FB),
        dividerTheme: DividerThemeData(
            space: 1.0, thickness: 1.0, color: Color(0xFF1b1b1b)),
        focusColor: Color(0xFF2699FB).withOpacity(0.5),
        cardColor: Color(0xFF2699FB),
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 40),
          headline2: TextStyle(color: Colors.white, fontSize: 25),
          headline3: TextStyle(color: Colors.white, fontSize: 20),
          headline4: TextStyle(color: Colors.white, fontSize: 18),
          headline6: TextStyle(color: Colors.white, fontSize: 15),
          bodyText2: TextStyle(color: Colors.white, fontSize: 15),
        ),
        dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18)),
        appBarTheme: AppBarTheme(
          color: Color(0xFF03151d),
          elevation: 0,
        ),
        sliderTheme: SliderThemeData(
          thumbColor: Colors.white,
          trackHeight: 2.25,
          activeTrackColor: Colors.white,
          inactiveTrackColor: Color(0xFFBCE0FD),
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        tabBarTheme: TabBarTheme(
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Colors.blue),
                insets: EdgeInsets.zero),
            labelColor: Color(0xFF2699FB),
            unselectedLabelColor: Colors.white));

// ignore: non_constant_identifier_names
ExtraThemeData DarkExtraTheme = ExtraThemeData(
    centerPageDetails: Color(0xFF9D9D9D),
    circleAvatarIcon: Colors.white,
    boxDetails: Colors.white,
    boxOuterBackground: Color(0xFF03151d),
    boxBackground: Color(0xFF032738),
    activeSwitch: Color(0xFF2699FB),
    textDetails: DarkTheme.primaryColor,
    bottomNavigationAppbar: DarkTheme.appBarTheme.color.withAlpha(200),
    activePageIcon: Colors.white,
    inactivePageIcon: Color(0xFF9D9D9D),
    menuIconButton: DarkTheme.accentColor.withAlpha(50),
    popupMenuButton: Colors.black,
    popupMenuButtonDetails: Colors.white,
    searchBox: DarkTheme.accentColor.withAlpha(50),
    chatOrContactItemDetails: Colors.white,
    //info chat in extra
    sentMessageBox: DarkTheme.primaryColor,
    receivedMessageBox: DarkTheme.accentColor.withAlpha(60),
    textMessage: Colors.white,
    messageDetails: Color(0xFF001D39),
    titleStatus: Colors.blue,
    persistentEventMessage: DarkTheme.accentColor.withAlpha(50),
    circularFileStatus: Color(0xFFBCE0FD),
    fileMessageDetails: DarkTheme.primaryColor,
    textField: Colors.white,
    username: Colors.yellowAccent,
    seenStatus: Colors.white,
    inputBoxBackground: DarkTheme.accentColor.withAlpha(50),
    pinMessageTheme: Color(0xFF263238),
    mentionWidget: Color(0xFF263238),
    border: DarkTheme.primaryColor);
