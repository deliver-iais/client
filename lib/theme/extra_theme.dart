import 'package:flutter/material.dart';

class ExtraThemeData {
  Color centerPageDetails;
  Color boxOuterBackground = Color(0xfde2f8f0);
  Color boxBackground = Color(0xfde2f8f0);
  Color menuIconButton;
  Color chatOrContactItemDetails;
  Color sentMessageBox;
  Color receivedMessageBox;
  Color persistentEventMessage;
  Color seenStatus; //green white
  Color messageDetails;
  Color circularFileStatus;
  Color fileMessageDetails;
  Color inputBoxBackground;
  Color fileSharingDetails;

  // TODO refactor all of these
  Color username; // primary
  Color textMessage; // -> normal
  Color textField; //green white -> normal
  Color textDetails; //light green - blue -> accent

  ExtraThemeData(
      {required this.centerPageDetails,
      required this.boxOuterBackground,
      required this.boxBackground,
      required this.textDetails,
      required this.menuIconButton,
      required this.username,
      required this.chatOrContactItemDetails,
      required this.sentMessageBox,
      required this.receivedMessageBox,
      required this.textMessage,
      required this.seenStatus,
      required this.messageDetails,
      required this.persistentEventMessage,
      required this.circularFileStatus,
      required this.fileMessageDetails,
      required this.textField,
      required this.inputBoxBackground,
      required this.fileSharingDetails});
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  ExtraTheme({
    Key? key,
    required Widget child,
    required this.extraThemeData,
  })  : assert(child != null),
        super(key: key, child: child);

  static ExtraThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ExtraTheme>()!
        .extraThemeData;
  }

  @override
  bool updateShouldNotify(ExtraTheme old) {
    // TODO ???
    return true;
  }
}
