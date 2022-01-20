import 'package:flutter/material.dart';

class ExtraThemeData {
  Color centerPageDetails;
  Color boxOuterBackground = const Color(0xfde2f8f0);
  Color boxBackground = const Color(0xfde2f8f0);
  Color chatOrContactItemDetails;
  Color sentMessageBoxBackground;
  Color circularFileStatus;
  Color fileMessageDetails;
  Color highlightOnSentMessage;
  Color onHighlightOnSentMessage;
  Color lowlightOnSentMessage;
  Color highlight;
  Color onHighlight;
  Color lowlight;
  Color onDetailsBox;

  ExtraThemeData({
    required this.centerPageDetails,
    required this.boxOuterBackground,
    required this.boxBackground,
    required this.chatOrContactItemDetails,
    required this.sentMessageBoxBackground,
    required this.circularFileStatus,
    required this.fileMessageDetails,
    required this.highlightOnSentMessage,
    required this.onHighlightOnSentMessage,
    required this.lowlightOnSentMessage,
    required this.highlight,
    required this.onHighlight,
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
    return false;
  }
}
