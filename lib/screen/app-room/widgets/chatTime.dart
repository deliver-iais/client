import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';
import 'package:flutter/material.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime, previousMessageTime;

  const ChatTime({Key key, this.currentMessageTime, this.previousMessageTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        'currentMessageTime : $currentMessageTime, previousMessageTime : $previousMessageTime');
    final ValueNotifier<int> day = ValueNotifier<int>(DateTime.now().day);
    return ValueListenableBuilder<int>(
      valueListenable: day,
      builder: (context, value, _) {
        bool newTime = false;
        if (previousMessageTime == null)
          newTime = true;
        else if (previousMessageTime.day != currentMessageTime.day ||
            previousMessageTime.month != currentMessageTime.month) {
          newTime = true;
        }
        if (!newTime)
          return Container();
        else {
          String outT = '';
          int currentDay = DateTime.now().day;
          int currentMonth = DateTime.now().month;
          if (currentDay == currentMessageTime.day &&
              currentMonth == currentMessageTime.month) {
            outT = 'Today';
          } else
            outT = currentMessageTime.dateTimeFormat();
          return Text(
            outT,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 13,
            ),
          );
        }
      },
    );
  }
}
