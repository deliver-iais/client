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

    late final String text;

    if (callHour.isNotEmpty) {
      text =
          "$callHour ${_i18n.get("hour")} ${_i18n.get("and")} $callMin ${_i18n.get("minutes")}";
    } else if (callMin.isNotEmpty) {
      text =
          "$callMin ${_i18n.get("minutes")} ${_i18n.get("and")} $callSec ${_i18n.get("seconds")}";
    } else {
      text = "$callSec ${_i18n.get("seconds")}";
    }

    return time.microsecondsSinceEpoch != 0
        ? Text(
            text,
            textDirection: _i18n.defaultTextDirection,
            style: theme.textTheme.bodySmall,
          )
        : const SizedBox.shrink();
  }
}
