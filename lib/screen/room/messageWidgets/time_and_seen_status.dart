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
  final bool showBackground;

  const TimeAndSeenStatus(
    this.message, {
    Key? key,
    required this.isSender,
    required this.isSeen,
    this.needsPositioned = true,
    this.needsPadding = false,
    this.showBackground = false,
  }) : super(key: key);

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
    final theme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: needsPadding
            ? const EdgeInsets.only(bottom: 2, right: 4, left: 4)
            : null,
        decoration: BoxDecoration(
          color: showBackground ? theme.surface : null,
          borderRadius: tertiaryBorder,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: theme.onSurface,
            fontSize: 13,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.edited) Text(_i18n.get("edited")),
              MsgTime(time: date(message.time)),
              if (isSender)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: SeenStatus(
                    message.roomUid,
                    message.packetId,
                    messageId: message.id,
                    isSeen: isSeen,
                    iconColor: theme.onSurface,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
