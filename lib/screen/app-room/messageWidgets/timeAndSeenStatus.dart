import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:flutter/material.dart';

class TimeAndSeenStatus extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isRounded;
  TimeAndSeenStatus(this.message, this.isSender, this.isRounded);
  @override
  Widget build(BuildContext context) {
    if (isRounded) {
      return Positioned(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(3),
                child: MsgTime(
                  time: message.time,
                ),
              ),
              isSender
                  ? Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: SeenStatus(message),
                    )
                  : Container(),
            ],
          ),
        ),
        right: 5,
        bottom: 5,
      );
    } else {
      return Positioned(
        child: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: MsgTime(
                  time: message.time,
                ),
              ),
              isSender
                  ? Padding(
                      padding:
                          const EdgeInsets.only(left: 3, right: 3.0, top: 5),
                      child: SeenStatus(message),
                    )
                  : Container(),
            ],
          ),
        ),
        right: 0,
        bottom: 0,
      );
    }
  }
}
