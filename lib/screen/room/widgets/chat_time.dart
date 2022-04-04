import 'package:deliver/shared/methods/time.dart';
import 'package:flutter/material.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({Key? key, required this.currentMessageTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var outT = '';
    final currentDay = DateTime.now().day;
    final currentMonth = DateTime.now().month;
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
      child: Chip(side: BorderSide.none, label: Text(outT)),
    );
  }
}
