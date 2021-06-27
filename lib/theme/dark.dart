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
    dividerTheme: DividerThemeData(space: 1.0, thickness: 1.0, color: Color(0xFF1b1b1b)),
    focusColor: Color(0xFF2699FB).withOpacity(0.5),
    cardColor: Color(0xFF2699FB),
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
    circleAvatarBackground: Color(0xFF2699FB),
    centerPageDetails: Color(0xFF9D9D9D),
    circleAvatarIcon: Colors.white,
    // active: Colors.white,
    // infoChat: Colors.white,
    // text: Color(0xFFBCE0FD),
    boxDetails: Colors.white,
    boxBackground: Color(0x8bc1e0FF).withAlpha(50),
    activeSwitch: Color(0xFF2699FB),
    //homePage
    textDetails : DarkTheme.primaryColor,
    bottomNavigationAppbar : DarkTheme.appBarTheme.color.withAlpha(200),
    activePageIcon : Colors.white,//active in extra
    inactivePageIcon : Color(0xFF9D9D9D),//details in extra
    menuIconButton : DarkTheme.accentColor.withAlpha(50),
    // popupMenuButton : Color(0x8b848b93),
    popupMenuButton : Colors.black,
    popupMenuButtonDetails : Colors.white,
    searchBox: DarkTheme.accentColor.withAlpha(50),
    chatOrContactItemDetails : Colors.white,//info chat in extra
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
    profileAvatarCard: DarkTheme.accentColor.withAlpha(50),
    inputBoxBackground: DarkTheme.accentColor.withAlpha(50),
    pinMessageTheme:  Color(0xFF263238),
  border: DarkTheme.primaryColor
);