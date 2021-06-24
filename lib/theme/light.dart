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
    backgroundColor: Color(0xfde2f8f0),
    buttonColor: Color(0xff1f655d),
    dividerTheme: DividerThemeData(space: 1.0, thickness: 1.0, color: Color(0xFFf0f0f0)),
    focusColor: Color(0xff179c96).withOpacity(0.5),
    cardColor: Color(0xff489088),
    textTheme: TextTheme(
      headline1: TextStyle(color: Colors.white, fontSize: 40),
      headline2: TextStyle(
          color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
      headline3: TextStyle(color: Colors.black, fontSize: 20),
      headline4: TextStyle(color: Colors.white, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xff002121))
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Color(0xff4bd5af),
      trackHeight: 2.25,
      activeTrackColor: Color(0xff4bd5af),
      inactiveTrackColor: Color(0xff179c96),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.5),
    ),
    iconTheme: IconThemeData(color: Color(0xff002121)),
    tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.blue),
            insets: EdgeInsets.zero),
        labelColor: Color(0xff179c96),
        unselectedLabelColor: Color(0xff002121),
        ));

// ignore: non_constant_identifier_names
ExtraThemeData LightExtraTheme = ExtraThemeData(
  circleAvatarBackground: Color(0xFF2699FB),
  centerPageDetails: Color(0xff0b796c),
  circleAvatarIcon: Colors.white,
  // secondColor: Colors.white,
  // active: Color(0xff174b45),
  // infoChat: Colors.black,
  // text: Colors.white,
  boxDetails: Color(0xff15786c),
  boxBackground: Colors.white,
  activeSwitch: Color(0xff15786c),
  textDetails : Colors.black,
  //homePage
    bottomNavigationAppbar : LightTheme.appBarTheme.color,
    activePageIcon: LightTheme.accentColor,
    inactivePageIcon : LightTheme.accentColor.withAlpha(100), //details in extra
    menuIconButton : LightTheme.accentColor.withAlpha(50),
    popupMenuButton : Colors.white,
    popupMenuButtonDetails : LightTheme.accentColor,
    searchBox: Color(0xFFEEEEEE),
    chatOrContactItemDetails : Colors.black,//info chat in extra
    // roomPage
    sentMessageBox:  Color(0xFFDCEDC8),
    receivedMessageBox: Colors.white,
    textMessage: LightTheme.accentColor,
    messageDetails: LightTheme.accentColor.withAlpha(200),
    persistentEventMessage: LightTheme.backgroundColor,
    circularFileStatus: LightTheme.backgroundColor,
    fileMessageDetails: Color(0xff00a394),
    textField: LightTheme.accentColor,
    username: Colors.blue,
    titleStatus: Colors.blue,
    seenStatus: Colors.blue,
    pinMessageTheme:Color(0xFFDCEDC8),


    profileAvatarCard:Color(0xFFEEEEEE),
    inputBoxBackground: Colors.white,
   //group
  border: Color(0xff174b45),
  // text1 : white black
  // text2 : blue ligth green
  // text3 : white dark green
);

// SendingFileCircularIndicator