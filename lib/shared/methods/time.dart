import 'package:date_time_format/date_time_format.dart';
import 'package:deliver_flutter/shared/constants.dart';

bool isOnline(int time) {
  return DateTime.now().millisecondsSinceEpoch - time < ONLINE_TIME;
}

DateTime date(int time) {
  if (time == null) time = 0;
  return DateTime.fromMillisecondsSinceEpoch(time);
}

String durationTimeFormat(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String dateTimeFormat(DateTime time) {
  var now = DateTime.now();
  var difference = now.difference(time);
  if (difference.inMinutes <= 2) {
    return "just now";
  } else if (difference.inDays < 1 && time.day == now.day) {
    return DateTimeFormat.format(time, format: 'H:i');
  } else if (difference.inDays <= 7)
    return DateTimeFormat.format(time, format: 'D');
  else
    return DateTimeFormat.format(time, format: 'M j');
}