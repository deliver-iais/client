import 'dart:math';

import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/navigation_center/chats/widgets/lastMessage.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sorted_list/sorted_list.dart';

class PinMessageAppBar extends StatelessWidget {
  final BehaviorSubject<int> lastPinedMessage;
  final SortedList<Message> pinMessages;
  final Function onTap;
  final Function onNext;
  final Function onPrev;
  final Function onCancel;

  PinMessageAppBar(
      {Key key,
      this.lastPinedMessage,
      this.pinMessages,
      this.onTap,
      this.onCancel,
      this.onNext,
      this.onPrev})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return StreamBuilder<int>(
        stream: lastPinedMessage.stream,
        builder: (c, id) {
          if (id.hasData && id.data > 0) {
            Message mes;
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
                    color: ExtraTheme.of(context).pinMessageTheme,
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
                              style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            LastMessage(
                                message: mes,
                                lastMessageId: mes.id,
                                hasMentioned: false,
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
