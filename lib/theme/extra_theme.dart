import 'package:flutter/material.dart';

class ExtraThemeData {
  Color centerPageDetails;
  Color boxOuterBackground = const Color(0xfde2f8f0);
  Color boxBackground = const Color(0xfde2f8f0);
  Color menuIconButton;
  Color chatOrContactItemDetails;
  Color seenStatus; //green white

  Color sentMessageBoxBackground;
  Color defaultBackground;

  Color circularFileStatus;
  Color fileMessageDetails;

  Color highlightOnSentMessage;
  Color lowlightOnSentMessage;

  Color highlight;
  Color lowlight;

  Color onDetailsBox;

  Color inputBoxBackground;
  Color fileSharingDetails;

  // TODO refactor all of these
  Color username; // primary
  Color textDetails;

  ExtraThemeData({
    required this.centerPageDetails,
    required this.boxOuterBackground,
    required this.boxBackground,
    required this.textDetails,
    required this.menuIconButton,
    required this.username,
    required this.chatOrContactItemDetails,
    required this.sentMessageBoxBackground,
    required this.defaultBackground,
    required this.seenStatus,
    required this.circularFileStatus,
    required this.fileMessageDetails,
    required this.inputBoxBackground,
    required this.fileSharingDetails,
    required this.highlightOnSentMessage,
    required this.lowlightOnSentMessage,
    required this.highlight,
    required this.lowlight,
    required this.onDetailsBox,
  });
}

class ExtraTheme extends InheritedWidget {
  final ExtraThemeData extraThemeData;

  const ExtraTheme({
    Key? key,
    required Widget child,
    required this.extraThemeData,
  }) : super(key: key, child: child);

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
