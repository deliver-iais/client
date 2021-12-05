import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class CallTime extends StatelessWidget {
  final DateTime time;

  const CallTime({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String callHour = time.hour.toString();
    String callMin = time.minute.toString();
    String callSec = time.second.toString();
    if (callHour.length != 2) {
      callHour = '0' + callHour;
    } else {
      callHour = callHour;
    }
    callMin = callMin.length != 2 ? '0' + callMin : callMin;

    return Text(
      callHour + ':' + callMin + ':' + callSec ,
      style: TextStyle(
        fontSize: 11,
        height: 1.1,
        fontStyle: FontStyle.italic,
        color: ExtraTheme.of(context).textMessage.withAlpha(130),
      ),
    );
  }
}
