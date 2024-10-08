import 'package:flutter/material.dart';

class MsgTime extends StatelessWidget {
  final DateTime time;

  const MsgTime({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    var msgHour = time.hour.toString();
    var msgMin = time.minute.toString();
    msgHour = msgHour.length != 2 ? '0$msgHour' : msgHour;
    msgMin = msgMin.length != 2 ? '0$msgMin' : msgMin;

    return Text(
      '$msgHour:$msgMin',
      style: const TextStyle(fontStyle: FontStyle.italic),
    );
  }
}
