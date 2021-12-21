import 'dart:ui';

import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:flutter/material.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({Key? key, required this.currentMessageTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> day = ValueNotifier<int>(DateTime.now().day);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: BlurContainer(
        child: ValueListenableBuilder<int>(
            valueListenable: day,
            builder: (context, value, _) {
              String outT = '';
              int currentDay = DateTime.now().day;
              int currentMonth = DateTime.now().month;
              if (currentDay == currentMessageTime.day &&
                  currentMonth == currentMessageTime.month) {
                outT = ' Today ';
              } else if (currentDay - currentMessageTime.day < 2 &&
                  currentMonth == currentMessageTime.month) {
                outT = ' Yesterday ';
              } else {
                outT = dateTimeFormat(currentMessageTime, weekFormat: 'l');
              }
              return Text(
                outT,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(height: 1, color: Colors.white),
              );
            }),
      ),
    );
  }
}
