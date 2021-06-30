import 'package:date_time_format/date_time_format.dart';

import 'constants.dart';

bool isOnline(int time) {
  return DateTime.now().millisecondsSinceEpoch - time < ONLINE_TIME;
}

DateTime date(int time) {
  return DateTime.fromMillisecondsSinceEpoch(time);
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