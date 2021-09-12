import 'package:we/shared/methods/time.dart';
import 'package:flutter/material.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({Key key, this.currentMessageTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> day = ValueNotifier<int>(DateTime.now().day);
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding:
          const EdgeInsets.only(top: 5, left: 8.0, right: 8.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
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
            } else
              outT = dateTimeFormat(currentMessageTime, weekFormat: 'l');
            return Text(
              outT,
              style: Theme.of(context).textTheme.bodyText2.copyWith(height: 1, color: Colors.white),
            );
          }),
    );
  }
}
