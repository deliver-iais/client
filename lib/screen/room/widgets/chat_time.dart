import 'package:clock/clock.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../localization/i18n.dart';

class ChatTime extends StatelessWidget {
  final DateTime currentMessageTime;

  const ChatTime({super.key, required this.currentMessageTime});

  static final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Chip(
        label: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            outT,
            textDirection:
                _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        elevation: 2,
      ),
    );
  }
}
