import 'package:flutter/material.dart';

class ExtraThemeData {
  Color centerPageDetails = Color(0xFF9D9D9D);
  Color circleAvatarIcon = Colors.white;

  // Color text = Color(0xFFBCE0FD);
  Color blueOfProfilePage = Color(0xFF2699FB);
  Color backgroundOfProfilePage = Color(0xFF424242);
  Color borderOfProfilePage = Color(0xFF9D9D9D);
  Color boxDetails = Colors.white;
  Color boxOuterBackground = Color(0xfde2f8f0);
  Color boxBackground = Color(0xfde2f8f0);
  Color activeSwitch = Color(0xff15786c);
  Color textDetails; //light green - blue
  Color bottomNavigationAppbar;
  Color titleStatus;
  Color activePageIcon;
  Color inactivePageIcon;
  Color menuIconButton;
  Color popupMenuButton;
  Color popupMenuButtonDetails;
  Color chatOrContactItemDetails;
  Color searchBox;
  Color username;
  Color sentMessageBox;
  Color receivedMessageBox;
  Color textMessage;
  Color seenStatus; //green white
  Color messageDetails;
  Color persistentEventMessage;
  Color circularFileStatus;
  Color fileMessageDetails;
  Color textField; //green white
  Color inputBoxBackground;
  Color border;
  Color pinMessageTheme;
  Color mentionWidget;
  TextStyle verificationPinCode;

  ExtraThemeData({
    this.centerPageDetails,
    this.circleAvatarIcon,
    this.boxDetails,
    this.boxOuterBackground,
    this.boxBackground,
    this.activeSwitch,
    this.textDetails,
    this.bottomNavigationAppbar,
    this.activePageIcon,
    this.inactivePageIcon,
    this.menuIconButton,
    this.popupMenuButton,
    this.popupMenuButtonDetails,
    this.searchBox,
    this.username,
    this.titleStatus,
    this.chatOrContactItemDetails,
    this.sentMessageBox,
    this.receivedMessageBox,
    this.textMessage,
    this.seenStatus,
    this.messageDetails,
    this.persistentEventMessage,
    this.circularFileStatus,
    this.fileMessageDetails,
    this.textField,
    this.pinMessageTheme,
    this.inputBoxBackground,
    this.border,
    this.mentionWidget,
    this.verificationPinCode,
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
    // TODO ???
    return true;
  }
}
