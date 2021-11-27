import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/msgTime.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeAndSeenStatus extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final bool needsBackground;
  final bool needsPositioned;
  final bool needsPadding;

  TimeAndSeenStatus(this.message, this.isSender, this.isSeen,
      {this.needsPositioned = true,
      this.needsBackground = false,
      this.needsPadding = true});

  var _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final widget = buildWidget(context);

    if (needsPositioned)
      return Positioned(
        child: widget,
        right: 0,
        bottom: 0,
      );
    else
      return widget;
  }

  Widget buildWidget(BuildContext context) {
    return Container(
      padding: needsPadding
          ? const EdgeInsets.only(top: 0, bottom: 2, right: 4, left: 4)
          : null,
      margin: const EdgeInsets.all(2),
      decoration: needsBackground
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Theme.of(context).backgroundColor.withAlpha(150),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.edited != null && message.edited!)
            Text(
              _i18n.get("edited"),
              style: TextStyle(
                color: ExtraTheme.of(context).textMessage.withAlpha(130),
                fontSize: 13,
                height: 1.1,
              ),
            ),
          MsgTime(time: date(message.time), isSent: isSender),
          if (isSender)
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: SeenStatus(message, isSeen: isSeen),
            )
        ],
      ),
    );
  }
}
