import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MsgTime extends StatelessWidget {
  final DateTime time;
  final bool isSent;

  const MsgTime({Key? key, required this.time, this.isSent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msgHour = time.hour.toString();
    String msgMin = time.minute.toString();
    msgHour = msgHour.length != 2 ? '0' + msgHour : msgHour;
    msgMin = msgMin.length != 2 ? '0' + msgMin : msgMin;

    return Text(
      msgHour + ':' + msgMin,
      style: TextStyle(
        fontSize: 11,
        height: 1.1,
        fontStyle: FontStyle.italic,
        color: ExtraTheme.of(context).textMessage.withAlpha(130),
      ),
    );
  }
}
