import 'dart:convert';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    final botRepo = GetIt.I.get<BotRepo>();
    final widgetRows = <Widget>[];
    final rows = message.markup?.inlineKeyboardMarkup?.rows;
    var columns = <Widget>[];

    if (rows != null) {
      for (final row in rows) {
        columns = [];
        for (var i = 0; i < row.buttons.length; ++i) {
          final json = jsonDecode(row.buttons[i].json) as Map;
          final isUrlInlineKeyboardMarkup = json['url'] != null;
          columns.add(
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Stack(
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Color.alphaBlend(
                            Theme.of(context).primaryColor.withAlpha(50),
                            Colors.black12,
                          ),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: messageBorder,
                          ),
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      onPressed: () {
                        botRepo.handleInlineMarkUpMessageCallBack(
                            message, context, row.buttons[i].json,);
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            row.buttons[i].text,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isUrlInlineKeyboardMarkup)
                      const Positioned(
                        right: 3,
                        top: 3,
                        child: Icon(
                          Icons.call_made_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        widgetRows.add(
          IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: columns,
              ),
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
