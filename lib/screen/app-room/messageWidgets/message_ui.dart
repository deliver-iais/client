import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/image_message/image_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_header.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_message.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class MessageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final Function lastCross;
  final bool isSender;
  final CrossAxisAlignment last;
  const MessageUi(
      {Key key,
      this.message,
      this.maxWidth,
      this.lastCross,
      this.isSender,
      this.last})
      : super(key: key);

  @override
  _MessageUiState createState() => _MessageUiState();
}

class _MessageUiState extends State<MessageUi> {
  @override
  Widget build(BuildContext context) {
    String type = widget.message.json.toFile().type;
    return Column(
      crossAxisAlignment: widget.last,
      children: <Widget>[
        type == 'image'
            ? ImageUi(
                message: widget.message,
                maxWidth: widget.maxWidth,
                isSender: widget.isSender)
            : type == 'video'
                ? VideoMessage(
                    message: widget.message,
                    maxWidth: widget.maxWidth,
                    isSender: widget.isSender)
                : MessageHeader(
                    message: widget.message,
                    maxWidth: widget.maxWidth,
                    isSender: widget.isSender),
        widget.message.json.toFile().caption.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: TextUi(
                  message: widget.message,
                  maxWidth: widget.maxWidth,
                  lastCross: widget.lastCross,
                  isSender: widget.isSender,
                  isCaption: true,
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }
}
