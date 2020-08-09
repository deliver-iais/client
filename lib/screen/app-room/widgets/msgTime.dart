import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class MsgTime extends StatelessWidget {
  final DateTime time;

  const MsgTime({Key key, this.time}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String msgHour = time.hour.toString();
    String msgMin = time.minute.toString();
    msgHour = msgHour.length != 2 ? '0' + msgHour : msgHour;
    msgMin = msgMin.length != 2 ? '0' + msgMin : msgMin;

    return Text(
      msgHour + ':' + msgMin,
      style: TextStyle(
        fontSize: 12,
        color: ExtraTheme.of(context).details,
      ),
    );
  }
}
