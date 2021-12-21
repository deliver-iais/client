import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/blured_container.dart';
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
  final _i18n = GetIt.I.get<I18N>();

  TimeAndSeenStatus(this.message, this.isSender, this.isSeen,
      {Key? key,
      this.needsPositioned = true,
      this.needsBackground = false,
      this.needsPadding = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = buildWidget(context);

    if (needsPositioned) {
      return Positioned(
        child: widget,
        right: 0,
        bottom: 0,
      );
    } else {
      return widget;
    }
  }

  Widget buildWidget(BuildContext context) {
    return RepaintBoundary(
      child: BlurContainer(
        padding: needsPadding
            ? const EdgeInsets.only(top: 0, bottom: 2, right: 4, left: 4)
            : null,
        skew: 5,
        blurIsEnabled: needsBackground,
        child: DefaultTextStyle(
          style: TextStyle(
            color: needsBackground
                ? Colors.white
                : ExtraTheme.of(context).textMessage.withAlpha(130),
            fontSize: 12,
            height: 1.2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.edited != null && message.edited!)
                Text(_i18n.get("edited")),
              MsgTime(time: date(message.time)),
              if (isSender)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: SeenStatus(
                    message,
                    isSeen: isSeen,
                    iconColor: needsBackground
                        ? Colors.white
                        : ExtraTheme.of(context).seenStatus,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
