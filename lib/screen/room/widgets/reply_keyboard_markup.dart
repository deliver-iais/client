import 'package:deliver/box/reply_keyboard_markup.dart';

import 'package:flutter/material.dart';

class ReplyKeyboardMarkupWidget extends StatelessWidget {
  final ReplyKeyboardMarkup replyKeyboardMarkup;

  const ReplyKeyboardMarkupWidget({
    Key? key,
    required this.replyKeyboardMarkup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgetRows = <Widget>[];
    final rows = replyKeyboardMarkup.rows;
    var columns = <Widget>[];
    for (final row in rows) {
      columns = [];
      for (var i = 0; i < row.buttons.length; ++i) {
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
                    onPressed: () {},
                    child: Center(
                      child: Text(
                        row.buttons[i].text,
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
      constraints: const BoxConstraints(maxHeight: 300),
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
