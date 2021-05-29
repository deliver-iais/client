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
  Color connectionStatus;
  Color bottomNavigationAppbar;
  Color activePageIcon;
  Color inactivePageIcon;
  Color menuIconButton;
  Color popupMenuButton;
  Color popupMenuButtonIcon;
  Color popupMenuButton2;
  Color localSearch;
  Color displayName;
  Color popupMenuButtonText;
  Color searchBox;
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
        this.connectionStatus,
        this.bottomNavigationAppbar,
        this.activePageIcon,
        this.inactivePageIcon,
        this.menuIconButton,
        this.popupMenuButton,
        this.popupMenuButtonIcon,
        this.popupMenuButtonText,
        this.searchBox,
        this.localSearch,
        this.displayName
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