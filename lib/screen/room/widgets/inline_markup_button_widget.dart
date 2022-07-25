import 'dart:convert';

import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/widgets/message_wrapper.dart';
import 'package:deliver/services/url_handler_service.dart';
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
    final urlHandlerService = GetIt.I.get<UrlHandlerService>();
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
              child: Stack(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                    ),
                    onPressed: () {
                      if (isUrlInlineKeyboardMarkup) {
                        urlHandlerService.onUrlTap(json['url'], context);
                      } else if (json['data'] != null) {
                        // TODO(fatemeh): ???,
                      }
                    },
                    child: MessageWrapper(
                      uid: message.from,
                      isSender: isSender,
                      isInlineMarkUpMessage: true,
                      isFirstMessageInGroupedMessages: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                    ),
                  ),
                  if (isUrlInlineKeyboardMarkup)
                    const Positioned(
                      right: 14,
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
