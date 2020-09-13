import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class BoxContent extends StatelessWidget {
  final Message message;
  final double maxWidth;

  const BoxContent({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.TEXT) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: TextUi(
          content: message.json.toText().text,
          maxWidth: maxWidth,
          isCaption: false,
        ),
      );
    } else if (message.type == MessageType.FILE) {
      return MessageUi(message: message, maxWidth: maxWidth);
    }
    return Container();
  }
}
