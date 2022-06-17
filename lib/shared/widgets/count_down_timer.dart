import 'dart:math';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:deliver/box/message.dart';
import 'package:flutter/material.dart';

class CountDownTimer extends StatelessWidget {
  final Message message;
  final int lockAfter;
  final Function(bool) lock;

  const CountDownTimer({
    super.key,
    required this.message,
    required this.lockAfter,
    required this.lock,
  });

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
        duration: lockAfter ~/ 1000,
        controller: CountDownController(),
        width: 30,
        strokeCap: StrokeCap.round,
        height: 30,
        initialDuration: min(
          lockAfter ~/ 1000,
          ((DateTime.now().millisecondsSinceEpoch - message.time).abs() / 1000)
              .round(),
        ),
        ringColor: Colors.black26,
        fillColor: Colors.amber,
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
