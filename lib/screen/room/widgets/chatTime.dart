import 'package:deliver_flutter/shared/methods/time.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({Key key, this.currentMessageTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> day = ValueNotifier<int>(DateTime.now().day);
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              outT = dateTimeFormat(currentMessageTime);
            return Text(
              outT,
              style: TextStyle(
                color: ExtraTheme.of(context).textDetails,
                fontSize: 13,
              ),
            );
          }),
    );
  }
}
