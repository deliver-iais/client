import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallTime extends StatelessWidget {
  final DateTime time;
  final _i18n = GetIt.I.get<I18N>();

  CallTime({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    final callHour = time.hour != 0 ? time.hour.toString() : "";
    final callMin = time.minute != 0 ? time.minute.toString() : "";
    final callSec = time.second != 0 ? time.second.toString() : "";
    final theme = Theme.of(context);

    return time.microsecondsSinceEpoch != 0
        ? Text(
            textDirection:
                _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
            style:
                theme.textTheme.bodySmall,

            callHour.isNotEmpty
                ? "$callHour ${_i18n.get("hour")} ${_i18n.get("and")} $callMin ${_i18n.get("minutes")}"
                : callMin.isNotEmpty
                    ? "$callMin ${_i18n.get("minutes")} ${_i18n.get("and")} $callSec ${_i18n.get("seconds")}"
                    : "$callSec ${_i18n.get("seconds")}",
          )
        : const SizedBox.shrink();
  }
}
