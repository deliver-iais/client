import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MsgTime extends StatelessWidget {
  final DateTime time;

  const MsgTime({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msgHour = time.hour.toString();
    String msgMin = time.minute.toString();
    msgHour = msgHour.length != 2 ? '0' + msgHour : msgHour;
    msgMin = msgMin.length != 2 ? '0' + msgMin : msgMin;

    return Text(
      msgHour + ':' + msgMin,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
