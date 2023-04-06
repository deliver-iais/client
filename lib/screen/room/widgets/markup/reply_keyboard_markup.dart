import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/markup.pb.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ReplyKeyboardMarkupWidget extends StatelessWidget {
  static final messageRepo = GetIt.I.get<MessageRepo>();
  final ReplyKeyboardMarkup replyKeyboardMarkup;
  final void Function() closeReplyKeyboard;
  final String roomUid;
  final InputMessageTextController textController;

  const ReplyKeyboardMarkupWidget({
    Key? key,
    required this.replyKeyboardMarkup,
    required this.closeReplyKeyboard,
    required this.roomUid,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.alphaBlend(
      Theme.of(context).colorScheme.primary.withAlpha(30),
      Theme.of(context).colorScheme.surface,
    );
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
                  padding: const EdgeInsetsDirectional.all(4),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.alphaBlend(
                          Theme.of(context).colorScheme.primary.withAlpha(60),
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
                        closeReplyKeyboard.call();
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
                          textController.text = textController.text.characters
                                  .getRange(0, start)
                                  .string +
                              button.text +
                              textController.text.characters
                                  .getRange(textController.selection.end)
                                  .string;
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: bgColor,
      ),
      child: Container(
        color: bgColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgetRows,
            ),
          ),
        ),
      ),
    );
  }
}
