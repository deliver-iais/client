import 'package:we/box/message.dart';
import 'package:we/screen/room/widgets/msgTime.dart';
import 'package:we/shared/methods/time.dart';
import 'package:we/shared/widgets/seen_status.dart';
import 'package:flutter/material.dart';

class TimeAndSeenStatus extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final bool needsBackground;
  final bool needsPositioned;
  final bool needsPadding;

  TimeAndSeenStatus(this.message, this.isSender, this.isSeen,
      {this.needsPositioned = true,
      this.needsBackground,
      this.needsPadding = true});

  @override
  Widget build(BuildContext context) {
    final widget = buildWidget(context);

    if (needsPositioned)
      return Positioned(
        child: widget,
        right: 0,
        bottom: 0,
      );
    else
      return widget;
  }

  Widget buildWidget(BuildContext context) {
    return Container(
      padding: needsPadding
          ? const EdgeInsets.only(top: 2, bottom: 2, right: 4, left: 4)
          : null,
      margin: const EdgeInsets.all(2),
      decoration: needsBackground
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).backgroundColor.withAlpha(150),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MsgTime(time: date(message.time), isSent: isSender),
          if (isSender) Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: SeenStatus(message, isSeen: isSeen),
          )
        ],
      ),
    );
  }
}
