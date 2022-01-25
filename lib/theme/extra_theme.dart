import 'package:flutter/material.dart';

class ExtraThemeData {
  Color chatOrContactItemDetails;
  Color sentMessageBoxBackground;
  Color highlightOnSentMessage;
  Color onHighlightOnSentMessage;
  Color lowlightOnSentMessage;
  Color highlight;
  Color onHighlight;
  Color lowlight;
  Color onDetailsBox;

  ExtraThemeData({
    required this.chatOrContactItemDetails,
    required this.sentMessageBoxBackground,
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
