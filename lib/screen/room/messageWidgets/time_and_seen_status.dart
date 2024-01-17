import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:flutter/cupertino.dart';
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
    super.key,
    required this.isSender,
    required this.isSeen,
    this.needsPositioned = true,
    this.needsPadding = false,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) => needsPositioned
      ? Positioned(
          right: 0,
          bottom: 0,
          child: buildWidget(context),
        )
      : buildWidget(context);

  Widget buildWidget(BuildContext context) {
    final theme = Theme.of(context);

    final color = theme.colorScheme.outline;
    final iconColor = theme.colorScheme.surfaceTint;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsetsDirectional.all(p2),
        padding: needsPadding
            ? const EdgeInsetsDirectional.only(top: 3, end: 6, start: 4)
            : null,
        decoration: BoxDecoration(
          color: showBackground ? theme.colorScheme.surface : null,
          borderRadius: mainBorder,
        ),
        child: DefaultTextStyle(
          style: (theme.textTheme.labelSmall ?? const TextStyle())
              .copyWith(color: color),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.edited) Text(_i18n.get("edited")),
              MsgTime(time: date(message.time)),
              if (isSender)
                Container(
                  transform: Matrix4.translationValues(0, -1, 0),
                  padding:
                      const EdgeInsetsDirectional.only(start: 3.0, bottom: 1.0),
                  child: SeenStatus(
                    message.roomUid,
                    message.packetId,
                    messageId: message.id,
                    isSeen: isSeen,
                    iconColor: iconColor,
                  ),
                ),

              if (message.isLocalMessage)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    CupertinoIcons.antenna_radiowaves_left_right,
                    size: 15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
