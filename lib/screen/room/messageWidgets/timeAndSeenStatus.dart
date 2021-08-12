import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/methods/time.dart';
import 'package:deliver_flutter/shared/widgets/seen_status.dart';
import 'package:flutter/material.dart';

class TimeAndSeenStatus extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool needsMorePadding;
  final bool isSeen;
  final bool needsPositioned;

  TimeAndSeenStatus(
      this.message, this.isSender, this.needsMorePadding, this.isSeen,
      {this.needsPositioned = true});

  @override
  Widget build(BuildContext context) {
    if (needsMorePadding) {
      return Positioned(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(3),
                child: MsgTime(
                  time: date(message.time),
                ),
              ),
              isSender
                  ? Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: SeenStatus(message, isSeen: isSeen),
                    )
                  : Container(),
            ],
          ),
        ),
        right: 5,
        bottom: 5,
      );
    } else {
      final widget = Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: MsgTime(
                time: date(message.time),
              ),
            ),
            isSender
                ? Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3.0, top: 5),
                    child: SeenStatus(message, isSeen: isSeen),
                  )
                : Container(),
          ],
        ),
      );
      if (needsPositioned)
        return Positioned(
          child: widget,
          right: 0,
          bottom: 0,
        );
      else
        return widget;
    }
  }
}
