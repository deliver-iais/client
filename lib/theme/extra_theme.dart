import 'package:flutter/material.dart';

class ExtraThemeData {
  Color centerPageDetails;
  Color boxOuterBackground = Color(0xfde2f8f0);
  Color boxBackground = Color(0xfde2f8f0);
  Color menuIconButton;
  Color popupMenuButton;
  Color popupMenuButtonDetails;
  Color chatOrContactItemDetails;
  Color searchBox;
  Color sentMessageBox;
  Color receivedMessageBox;
  Color seenStatus; //green white
  Color messageDetails;
  Color persistentEventMessage;
  Color circularFileStatus;
  Color fileMessageDetails;
  Color inputBoxBackground;

  // TODO Should be remove
  Color border;

  // TODO should be remove
  Color mentionAutoCompleter;

  // TODO refactor all of these
  Color username; // primary
  Color textMessage; // -> normal
  Color textField; //green white -> normal
  Color textDetails; //light green - blue -> accent

  ExtraThemeData({
    this.centerPageDetails,
    this.boxOuterBackground,
    this.boxBackground,
    this.textDetails,
    this.menuIconButton,
    this.popupMenuButton,
    this.popupMenuButtonDetails,
    this.searchBox,
    this.username,
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
    this.inputBoxBackground,
    this.border,
    this.mentionAutoCompleter,
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
