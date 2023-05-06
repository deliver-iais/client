import 'package:clock/clock.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:deliver/shared/constants.dart';
import 'package:get_it/get_it.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../localization/i18n.dart';

final _i18n = GetIt.I.get<I18N>();

bool isOnline(int time) {
  return clock.now().millisecondsSinceEpoch - time < ONLINE_TIME;
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

String dateTimeFromNowFormat(DateTime time, {bool summery = false}) {
  final now = clock.now();
  final difference = now.difference(time);
  final isInSameYear = _i18n.isPersian
      ? Jalali.fromDateTime(time).year == Jalali.fromDateTime(now).year
      : now.year == time.year;
  if (isInSameYear && difference.inDays < 1 && time.day == now.day) {
    return DateTimeFormat.format(time, format: 'H:i');
  } else if (isInSameYear) {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time).deliverFormat(summery: summery);
    } else {
      return DateTimeFormat.format(time, format: 'D, F j');
    }
  } else {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time)
          .deliverFormat(summery: summery, showYear: true);
    } else {
      return DateTimeFormat.format(time, format: 'D, F j, Y');
    }
  }
}

String dateTimeFormat(DateTime time) {
  return DateTimeFormat.format(
    time,
    format: AmericanDateFormats.standardAbbrWithComma,
  );
}

List<String> _deliverDayName = [
  'شنبه',
  'یکشنبه',
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنجشنبه',
  'جمعه',
];

List<String> _deliverShortDayName = [
  'ش',
  'ی',
  'د',
  'س',
  'چ',
  'پ',
  'ج',
];

extension DeliverJalaliFormats on Jalali {
  String deliverFormat({bool showYear = false, bool summery = false}) {
    final f = formatter;
    if (summery) {
      return '${_deliverShortDayName[weekDay - 1]}, ${f.d} ${f.mN}${showYear ? ",${f.yyyy}" : ""}';
    } else {
      return '${_deliverDayName[weekDay - 1]}, ${f.d} ${f.mN}';
    }
  }
}
