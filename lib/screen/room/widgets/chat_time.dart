import 'package:clock/clock.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/blurred_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({
    super.key,
    required this.currentMessageTime,
  });

  static final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var outT = '';
    final currentDay = clock.now().day;
    final currentMonth = clock.now().month;
    if (currentDay == currentMessageTime.day &&
        currentMonth == currentMessageTime.month) {
      outT = _i18n.get("today");
    } else if (currentDay - currentMessageTime.day < 2 &&
        currentMonth == currentMessageTime.month) {
      outT = _i18n.get("yesterday");
    } else {
      outT = dateTimeFromNowFormat(currentMessageTime, weekFormat: 'l');
    }
    return BlurContainer(
      skew: 5,
      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
      padding: const EdgeInsetsDirectional.only(
        top: p4,
        end: p8,
        start: p8,
      ),
      child: Text(
        outT,
        style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        textDirection: _i18n.defaultTextDirection,
      ),
    );
  }
}
