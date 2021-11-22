import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/lastMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sorted_list/sorted_list.dart';

class PinMessageAppBar extends StatelessWidget {
  final BehaviorSubject<int> lastPinedMessage;
  final SortedList<Message> pinMessages;
  final Function() onTap;
  final Function()? onNext;
  final Function? onPrev;
  final Function onCancel;

  PinMessageAppBar(
      {Key? key,
      required this.lastPinedMessage,
      required this.pinMessages,
      required this.onTap,
      required this.onCancel,
      this.onNext,
      this.onPrev})
      : super(key: key);

  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: lastPinedMessage.stream,
        builder: (c, id) {
          if (id.hasData && id.data! > 0) {
            Message? mes;
            pinMessages.forEach((m) {
              if (m.id == id.data) {
                mes = m;
              }
            });

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    // borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).dividerColor,
                        blurRadius: 2,
                        offset: Offset(1, 1), // Shadow position
                      ),
                    ],
                  ),
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          if (pinMessages.length > 2)
                            Container(
                              width: 3,
                              height:
                                  (52 / min(pinMessages.length.toDouble(), 3)) -
                                      4,
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              color: color(context, 0),
                            ),
                          if (pinMessages.length > 1)
                            Container(
                              width: 3,
                              height:
                                  (52 / min(pinMessages.length.toDouble(), 3)) -
                                      4,
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              color: color(context, 1),
                            ),
                          if (pinMessages.length > 1)
                            Container(
                              width: 3,
                              height:
                                  (52 / min(pinMessages.length.toDouble(), 3)) -
                                      4,
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              color: color(context, 2),
                            ),
                        ],
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i18n.get("pinned_message"),
                              style:
                                  Theme.of(context).primaryTextTheme.subtitle2,
                            ),
                            LastMessage(
                                message: mes!,
                                lastMessageId: mes!.id!,
                                hasMentioned: false,
                                showSeenStatus: false,
                                showSender: false),
                          ],
                        ),
                      ),
                      IconButton(
                          iconSize: 20,
                          onPressed: () {
                            onCancel();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).primaryColor,
                          ))
                    ],
                  ),
                ),
              ),
            );
          } else
            return SizedBox.shrink();
        });
  }

  Color color(BuildContext context, int index) {
    return highlight(index, lastPinedMessage.value)
        ? Theme.of(context).primaryColor
        : Theme.of(context).dividerColor;
  }

  bool highlight(int index, int id) {
    return (index == 2 && id == pinMessages.last.id) ||
        (index == 0 && id == pinMessages.first.id) ||
        (index == 1 && pinMessages.length == 2 && id == pinMessages.first.id) ||
        (index == 1 &&
            pinMessages.length > 2 &&
            id != pinMessages.first.id &&
            id != pinMessages.last.id);
  }
}
