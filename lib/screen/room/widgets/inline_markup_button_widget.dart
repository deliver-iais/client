import 'dart:convert';

import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/widgets/message_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InlineMarkUpButtonWidget extends StatelessWidget {
  final Message message;
  final bool isSender;

  const InlineMarkUpButtonWidget({
    Key? key,
    required this.message,
    required this.isSender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgetRows = <Widget>[];
    final rows = message.markup?.inlineKeyboardMarkup?.rows;
    var columns = <Widget>[];

    if (rows != null) {
      for (final row in rows) {
        columns = [];
        for (var i = 0; i < row.buttons.length; ++i) {
          columns.add(
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  final json = jsonDecode(row.buttons[i].json) as Map;
                  if (json['url'] != null) {
                    // TODO(fatemeh): change this line after merge markdown,
                    launch(json['url']);
                  } else if (json['data'] != null) {
                    // TODO(fatemeh): ???,
                  }
                },
                child: MessageWrapper(
                  uid: message.from,
                  isSender: isSender,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        row.buttons[i].text,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  isInlineMarkUpMessage: true,
                  isFirstMessageInGroupedMessages: false,
                ),
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
      return Column(
        children: widgetRows,
      );
    }
    return const SizedBox.shrink();
  }
}
