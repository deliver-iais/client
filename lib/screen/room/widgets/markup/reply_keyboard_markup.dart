import 'package:deliver/box/reply_keyboard_markup.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class ReplyKeyboardMarkupWidget extends StatelessWidget {
  final ReplyKeyboardMarkup replyKeyboardMarkup;
  final BehaviorSubject<bool> showReplyMarkUp;
  final String roomUid;
  final InputMessageTextController textController;

  const ReplyKeyboardMarkupWidget({
    Key? key,
    required this.replyKeyboardMarkup,
    required this.showReplyMarkUp,
    required this.roomUid,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageRepo = GetIt.I.get<MessageRepo>();
    final widgetRows = <Widget>[];
    final rows = replyKeyboardMarkup.rows;
    var columns = <Widget>[];
    for (final row in rows) {
      columns = [];
      for (var i = 0; i < row.buttons.length; ++i) {
        final button = row.buttons[i];
        columns.add(
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.alphaBlend(
                          Theme.of(context).primaryColor.withAlpha(60),
                          Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    onPressed: () {
                      if (replyKeyboardMarkup.oneTimeKeyboard) {
                        showReplyMarkUp.add(false);
                      }
                      if (button.sendOnClick) {
                        messageRepo.sendTextMessage(
                          roomUid.asUid(),
                          button.text,
                        );
                      } else {
                        final start = textController.selection.start;
                        if (start == -1) {
                          textController.text =
                              textController.text + button.text;
                        } else {
                          textController.text =
                              textController.text.substring(0, start) +
                                  button.text +
                                  textController.text
                                      .substring(textController.selection.end);
                        }
                      }
                    },
                    child: Center(
                      child: Text(
                        button.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widgetRows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: columns,
          ),
        ),
      );
    }
    return Container(
      color: Color.alphaBlend(
        Theme.of(context).primaryColor.withAlpha(30),
        Theme.of(context).colorScheme.surface,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widgetRows,
          ),
        ),
      ),
    );
  }
}
