import 'package:flutter/material.dart';

class CallTime extends StatelessWidget {
  final DateTime time;

  const CallTime({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    final callHour = time.hour != 0 ? time.hour.toString() : "";
    final callMin = time.minute != 0 ? time.minute.toString() : "";
    final callSec = time.second != 0 ? time.second.toString() : "";

    return time.microsecondsSinceEpoch != 0
        ? Text(
            callHour.isNotEmpty
                ? "$callHour hour and ${callMin}minute"
                : callMin.isNotEmpty
                    ? "$callMin minute"
                    : "$callSec second",
          )
        : const SizedBox.shrink();
  }
}
