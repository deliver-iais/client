import 'package:clock/clock.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:flutter/material.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({super.key, required this.currentMessageTime});

  @override
  Widget build(BuildContext context) {
    var outT = '';
    final currentDay = clock.now().day;
    final currentMonth = clock.now().month;
    if (currentDay == currentMessageTime.day &&
        currentMonth == currentMessageTime.month) {
      outT = 'Today';
    } else if (currentDay - currentMessageTime.day < 2 &&
        currentMonth == currentMessageTime.month) {
      outT = 'Yesterday';
    } else {
      outT = dateTimeFromNowFormat(currentMessageTime, weekFormat: 'l');
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Chip(
        label: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(outT),
        ),
        elevation: 2,
      ),
    );
  }
}
