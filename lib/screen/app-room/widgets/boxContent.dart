import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class BoxContent extends StatelessWidget {
  final Message message;
  final double maxWidth;

  const BoxContent({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     Fimber.d(message.toString());
    if (message.type == MessageType.text) {
      return TextUi(
        content: message.json.toText().text,
        maxWidth: maxWidth,
      );
    } else if (message.type == MessageType.file) {
      return MessageUi(message: message, maxWidth: maxWidth);
    }
    return Container();
  }
}
