import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class PinMessageAppBar extends StatelessWidget {
  final BehaviorSubject<int> lastPinedMessage;
  final List<Message> pinMessages;
  final void Function() onTap;

  // TODO: why not using this
  final void Function()? onNext;

  // TODO: why not using this
  final void Function()? onPrev;
  final void Function() onCancel;

  final i18n = GetIt.I.get<I18N>();

  PinMessageAppBar({
    Key? key,
    required this.lastPinedMessage,
    required this.pinMessages,
    required this.onTap,
    required this.onCancel,
    this.onNext,
    this.onPrev,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<int>(
      stream: lastPinedMessage.stream,
      builder: (c, id) {
        if (id.hasData && id.data! > 0) {
          Message? mes;
          for (final m in pinMessages) {
            if (m.id == id.data) {
              mes = m;
            }
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Material(
                  elevation: 4,
                  borderRadius: secondaryBorder,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.inverseSurface,
                      borderRadius: secondaryBorder,
                    ),
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            if (pinMessages.length > 2)
                              Container(
                                width: 3,
                                height: (52 /
                                        min(
                                          pinMessages.length.toDouble(),
                                          3,
                                        )) -
                                    4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                color: color(context, 0),
                              ),
                            if (pinMessages.length > 1)
                              Container(
                                width: 3,
                                height: (52 /
                                        min(
                                          pinMessages.length.toDouble(),
                                          3,
                                        )) -
                                    4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                color: color(context, 1),
                              ),
                            if (pinMessages.length > 1)
                              Container(
                                width: 3,
                                height: (52 /
                                        min(
                                          pinMessages.length.toDouble(),
                                          3,
                                        )) -
                                    4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                color: color(context, 2),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (mes != null)
                                Text(
                                  i18n.get("pinned_message"),
                                  style: theme.primaryTextTheme.subtitle2
                                      ?.copyWith(
                                    color: theme.colorScheme.inversePrimary,
                                  ),
                                ),
                              if (mes != null)
                                LastMessage(
                                  message: mes,
                                  lastMessageId: mes.id!,
                                  showSeenStatus: false,
                                  primaryColor:
                                      theme.colorScheme.inversePrimary,
                                  naturalColor:
                                      theme.colorScheme.onInverseSurface,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          iconSize: 20,
                          onPressed: () {
                            onCancel();
                          },
                          icon: Icon(
                            CupertinoIcons.xmark,
                            color: theme.colorScheme.inversePrimary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Color color(BuildContext context, int index) {
    final theme = Theme.of(context);
    return shouldHighlight(index, lastPinedMessage.value)
        ? theme.colorScheme.inversePrimary
        : Color.lerp(
            theme.colorScheme.inversePrimary,
            theme.colorScheme.inverseSurface,
            0.8,
          )!;
  }

  bool shouldHighlight(int index, int id) {
    return (index == 2 && id == pinMessages.last.id) ||
        (index == 0 && id == pinMessages.first.id) ||
        (index == 1 && pinMessages.length == 2 && id == pinMessages.first.id) ||
        (index == 1 &&
            pinMessages.length > 2 &&
            id != pinMessages.first.id &&
            id != pinMessages.last.id);
  }
}
