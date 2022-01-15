import 'package:flutter/material.dart';

class ExtraThemeData {
  Color centerPageDetails;
  Color boxOuterBackground = const Color(0xfde2f8f0);
  Color boxBackground = const Color(0xfde2f8f0);
  Color menuIconButton;
  Color chatOrContactItemDetails;
  Color sentMessageBox;
  Color sentMessageBoxForeground;
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
  Color textDetails;

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
      required this.fileSharingDetails, required this.sentMessageBoxForeground});
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  const ExtraTheme({
    Key? key,
    required Widget child,
    required this.extraThemeData,
  })  : super(key: key, child: child);

  static ExtraThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ExtraTheme>()!
        .extraThemeData;
  }

  @override
  bool updateShouldNotify(ExtraTheme oldWidget) {
    // TODO ???
    return true;
  }
}
