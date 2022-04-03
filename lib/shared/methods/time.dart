import 'package:date_time_format/date_time_format.dart';
import 'package:deliver/shared/constants.dart';

bool isOnline(int time) {
  return DateTime.now().millisecondsSinceEpoch - time < ONLINE_TIME;
}

DateTime date(int time) {
  return DateTime.fromMillisecondsSinceEpoch(time);
}

String durationTimeFormat(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String dateTimeFromNowFormat(DateTime time, {String weekFormat = 'D'}) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference.inDays < 1 && time.day == now.day) {
    return DateTimeFormat.format(time, format: 'H:i');
  } else if (difference.inDays <= 7) {
    return DateTimeFormat.format(time, format: weekFormat);
  } else {
    return DateTimeFormat.format(time, format: 'M j');
  }
}

String dateTimeFormat(DateTime time) {
  return DateTimeFormat.format(
    time,
    format: AmericanDateFormats.standardAbbrWithComma,
  );
}
