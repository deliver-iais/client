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

String dateTimeFromNowFormat(DateTime time, {String weekFormat = 'D'}) {
  final now = clock.now();
  final difference = now.difference(time);
  if (difference.inDays < 1 && time.day == now.day) {
    // TODO(amirhossein): is it important?? [WHY YOU COMMENT WHIT - is is important?]
    return DateTimeFormat.format(time, format: 'H:i');
  } else if (difference.inDays <= 7) {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time).formatter.wN;
    } else {
      return DateTimeFormat.format(time, format: weekFormat);
    }
  } else if (difference.inDays <= 365) {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time).formatShortMonthDay();
    } else {
      return DateTimeFormat.format(time, format: 'M j');
    }
  } else {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time).formatFullDate();
    } else {
      return DateTimeFormat.format(time, format: 'M j');
    }
  }
}

String dateTimeFormat(DateTime time) {
  return DateTimeFormat.format(
    time,
    format: AmericanDateFormats.standardAbbrWithComma,
  );
}

String sameDayTitle(DateTime time) {
  final now = clock.now();
  final difference = now.difference(time);
  if (difference.inDays < 1 && time.day == now.day) {
    return _i18n.get("today");
  }
  if (difference.inDays <= 1 && time.day == now.day - 1) {
    return _i18n.get("yesterday");
  } else if (difference.inDays <= 7) {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time).formatter.wN;
    } else {
      return DateTimeFormat.format(time, format: 'l');
    }
  } else {
    if (_i18n.isPersian) {
      return Jalali.fromDateTime(time).formatShortMonthDay();
    } else {
      return DateTimeFormat.format(time, format: 'M j');
    }
  }
}
