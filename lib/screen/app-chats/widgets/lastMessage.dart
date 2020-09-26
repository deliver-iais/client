import 'dart:convert';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class LastMessage extends StatelessWidget {
  final Message message;

  const LastMessage({Key key, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String data;
    TextDirection td;
    String oneLine = message.type == MessageType.TEXT
        ? (message.json.toText().text.split('\n'))[0]
        : message.type == MessageType.PERSISTENT_EVENT
            ? jsonDecode(message.json)["text"]
            : 'File';
    if (oneLine.isPersian()) {
      td = TextDirection.rtl;
    } else
      td = TextDirection.ltr;
    data = oneLine;
    if (message.roomId.uid.category == Categories.Group &&
        message.type != MessageType.PERSISTENT_EVENT) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.from.substring(0, 5) + ':',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 13,
            ),
          ),
          Text(
            oneLine,
            maxLines: 1,
            textDirection: td,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              // color:
              //     : ExtraTheme.of(context).infoChat,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Container(
      width: 230,
      child: Text(
        data,
        maxLines: 1,
        textDirection: td,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          color: message.type == MessageType.PERSISTENT_EVENT
              ? Theme.of(context).primaryColor
              : ExtraTheme.of(context).infoChat,
          fontSize: 13,
        ),
      ),
    );
  }
}
