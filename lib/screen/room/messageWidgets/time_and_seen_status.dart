import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TimeAndSeenStatus extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  final Message message;
  final bool isSender;
  final bool isSeen;
  final bool needsPositioned;
  final bool needsPadding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TimeAndSeenStatus(this.message, this.isSender, this.isSeen,
      {Key? key,
      this.needsPositioned = true,
      this.needsPadding = true,
      this.backgroundColor,
      this.margin,
      this.foregroundColor})
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
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
        padding: needsPadding
            ? const EdgeInsets.only(top: 0, bottom: 2, right: 4, left: 4)
            : null,
        decoration:
            BoxDecoration(color: backgroundColor, borderRadius: tertiaryBorder),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor,
            fontSize: 13,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.edited != null && message.edited!)
                Text(_i18n.get("edited")),
              MsgTime(
                time: date(message.time),
              ),
              if (isSender)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: SeenStatus(
                    message,
                    isSeen: isSeen,
                    iconColor: foregroundColor,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
