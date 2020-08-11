import 'package:flutter/material.dart';

class ExtraThemeData {
  Color circleAvatarBackground = Color(0xFF2699FB);
  Color introColor = Color(0xFF5F5F5F);
  Color details = Color(0xFF9D9D9D);
  Color circleAvatarIcon = Colors.white;
  Color secondColor = Color(0xFF393939);
  Color active = Colors.white;
  Color infoChat = Colors.white;
  Color text = Color(0xFFBCE0FD);


  ExtraThemeData({this.circleAvatarBackground,
    this.introColor,
    this.details,
    this.circleAvatarIcon,
    this.secondColor,
    this.active,
    this.infoChat,
    this.text});
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  ExtraTheme({Key key,
    @required Widget child,
    @required this.extraThemeData,
  })
      : assert(child != null),
        super(key: key, child: child);

  static ExtraThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ExtraTheme>().extraThemeData;
  }

  @override
  bool updateShouldNotify(ExtraTheme old) {
    return true;
  }
}
