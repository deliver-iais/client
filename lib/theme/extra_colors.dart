import 'package:flutter/material.dart';

class ExtraThemeData {
  Color circleAvatarBackground = Color(0xFF2699FB);
  Color details = Color(0xFF9D9D9D);
  Color circleAvatarIcon = Colors.white;
  Color secondColor = Color(0xFF393939);
  Color active = Colors.white;
  Color infoChat = Colors.white;
  Color text = Color(0xFFBCE0FD);
  Color blueOfProfilePage = Color(0xFF2699FB);
  Color backgroundOfProfilePage = Color(0xFF424242);
  Color borderOfProfilePage = Color(0xFF9D9D9D);
  Color boxDetails = Colors.white;
  Color boxBackground = Color(0xfde2f8f0);
  Color activeKey = Color(0xff15786c);
  Color textDetails;
  Color bottomNavigationAppbar;
  Color activePageIcon;
  Color inactivePageIcon;
  Color menuIconButton;
  Color popupMenuButton;
  Color popupMenuButtonDetails;
  Color popupMenuButton2;
  Color displayName;
  Color searchBox;
  Color sentMessageBox;
  Color receivedMessageBox;
  Color textMessage;
  Color messageDetails;
  Color persistentEventMessage;
  ExtraThemeData(
      {this.circleAvatarBackground,
        this.details,
        this.circleAvatarIcon,
        this.secondColor,
        this.active,
        this.infoChat,
        this.text,
        this.boxDetails,
        this.boxBackground,
        this.activeKey,
        this.textDetails,
        this.bottomNavigationAppbar,
        this.activePageIcon,
        this.inactivePageIcon,
        this.menuIconButton,
        this.popupMenuButton,
        this.popupMenuButtonDetails,
        this.searchBox,
        this.displayName,
        this.sentMessageBox,
        this.receivedMessageBox,
        this.textMessage,
        this.messageDetails,
        this.persistentEventMessage
      });
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  ExtraTheme({
    Key key,
    @required Widget child,
    @required this.extraThemeData,
  })  : assert(child != null),
        super(key: key, child: child);

  static ExtraThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ExtraTheme>()
        .extraThemeData;
  }

  @override
  bool updateShouldNotify(ExtraTheme old) {
    return true;
  }
}