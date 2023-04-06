import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const PIN_APPBAR_HEIGHT = APPBAR_HEIGHT + p4;

class PinMessageAppBar extends StatelessWidget {
  final BehaviorSubject<int> lastPinedMessage;
  final List<Message> pinMessages;
  final void Function() onTap;
  final void Function() onClose;

  final _i18n = GetIt.I.get<I18N>();
  final _botRepo = GetIt.I.get<BotRepo>();

  PinMessageAppBar({
    super.key,
    required this.lastPinedMessage,
    required this.pinMessages,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemScrollController = ItemScrollController();
    return StreamBuilder<int>(
      stream: lastPinedMessage,
      builder: (c, id) {
        if (id.hasData && id.data! > 0) {
          Message? mes;
          int? index;
          for (var i = 0; i < pinMessages.length; i++) {
            if (pinMessages[i].id == id.data) {
              mes = pinMessages[i];
              index = i;
            }
          }

          if (itemScrollController.isAttached && index != null) {
            itemScrollController.scrollTo(
              index: index,
              alignment: 0.5,
              duration: AnimationSettings.superSlow,
            );
          }
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                onTap.call();
              },
              child: Material(
                elevation: 1,
                color: theme.colorScheme.surface,
                child: Container(
                  height: PIN_APPBAR_HEIGHT,
                  padding: const EdgeInsetsDirectional.only(
                    end: p8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: p4,
                        child: ScrollablePositionedList.builder(
                          itemScrollController: itemScrollController,
                          initialScrollIndex: index ?? 0,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: tertiaryBorder,
                                color: color(context, index),
                              ),
                              height: (PIN_APPBAR_HEIGHT /
                                  min(
                                    pinMessages.length.toDouble(),
                                    2.5,
                                  )),
                              margin: EdgeInsetsDirectional.only(top: index > 0 ? 2.0 : 0),
                            );
                          },
                          itemCount: pinMessages.length,
                          padding: EdgeInsets.zero,
                          // shrinkWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (mes != null) ...[
                              Row(
                                children: [
                                  Text(
                                    _i18n.get("pinned_message"),
                                    style: theme.primaryTextTheme.titleSmall
                                        ?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: p2),
                                  Text(
                                    "#${index != null ? index + 1 : ""}",
                                    style: theme.primaryTextTheme.titleSmall
                                        ?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              AsyncLastMessage(
                                message: mes,
                                showSeenStatus: false,
                                maxLine: 1,
                              ),
                            ]
                          ],
                        ),
                      ),
                      buildPinMessageActions(mes, context)
                    ],
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
        ? theme.colorScheme.primary
        : theme.colorScheme.inversePrimary;
  }

  bool shouldHighlight(int index, int id) {
    if (pinMessages[index].id == id) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildPinMessageActions(Message? mes, BuildContext context) {
    final theme = Theme.of(context);
    if (mes?.markup?.toMessageMarkup().inlineKeyboardMarkup.rows.length == 1 &&
        mes?.markup
                ?.toMessageMarkup()
                .inlineKeyboardMarkup
                .rows
                .first
                .buttons
                .length ==
            1) {
      final inlineKeyboardButton = mes!.markup!
          .toMessageMarkup()
          .inlineKeyboardMarkup
          .rows
          .first
          .buttons
          .first;
      return TextButton(
        onPressed: () => _botRepo.handleInlineMarkUpMessageCallBack(
          mes,
          inlineKeyboardButton,
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            theme.colorScheme.primary.withAlpha(50),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: secondaryBorder,
            ),
          ),
        ),
        child: Text(
          inlineKeyboardButton.text,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: p4),
        child: IconButton(
          onPressed: onClose,
          icon: Icon(
            CupertinoIcons.xmark,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }
  }
}
