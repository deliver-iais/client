import 'dart:math';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:deliver/box/message.dart';
import 'package:flutter/material.dart';

class CountDownTimer extends StatelessWidget {
  final Message message;
  final int lockAfter;
  final int currentTime;
  final Function(bool) lock;

  const CountDownTimer({
    Key? key,
    required this.message,
    required this.lockAfter,
    required this.currentTime,
    required this.lock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: 10,
        bottom: 25,
        right: 70,
      ),
      child: CircularCountDownTimer(
        // tod o check time be big of message time
        duration: lockAfter ~/ 1000,
        controller: CountDownController(),
        width: 30,
        height: 30,
        initialDuration: min(
          lockAfter ~/ 1000,
          ((currentTime - message.time).abs() /
                  1000)
              .round(),
        ),

        ringColor: Colors.red,
        fillColor: Colors.blueAccent,
        textStyle: Theme.of(context).textTheme.bodyText2,
        textFormat: CountdownTextFormat.S,
        isReverse: true,
        // autoStart: !lockData.data!,
        isReverseAnimation: true,
        onComplete: () => lock(true),
      ),
    );
  }
}
