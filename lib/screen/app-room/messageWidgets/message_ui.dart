import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/image_message/image_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_header.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class MessageUi extends StatefulWidget {
  final Message message;

  final double maxWidth;

  const MessageUi({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  _MessageUiState createState() => _MessageUiState();
}

class _MessageUiState extends State<MessageUi> {
  CrossAxisAlignment last = CrossAxisAlignment.start;

  void initiaLastCross(CrossAxisAlignment c) {
    last = c;
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.message.json.toFile().type;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: last,
        children: <Widget>[
          type == 'image'
              ? ImageUi()
              : type == 'video'
                  ? VideoUi()
                  : MessageHeader(
                      message: widget.message, maxWidth: widget.maxWidth),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextUi(
                content: widget.message.json.toFile().caption,
                maxWidth: widget.maxWidth,
                lastCross: this.initiaLastCross),
          )
        ],
      ),
    );
  }
}
