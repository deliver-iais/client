import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final Function scrollToMessage;
  final bool isSeen;
  final Function omUsernameClick;
  final String pattern;

  const SentMessageBox(
      {Key key,
      this.message,
      this.maxWidth,
      this.isSeen,
      this.scrollToMessage,
      this.pattern,
      this.omUsernameClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        message.type == MessageType.STICKER
            ? BoxContent(
                message: message,
                maxWidth: maxWidth,
                isSender: true,
                scrollToMessage: scrollToMessage,
                isSeen: this.isSeen,
                onUsernameClick: this.omUsernameClick,
                pattern: this.pattern,
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    color: Theme.of(context).primaryColor,
                    child: BoxContent(
                      message: message,
                      maxWidth: maxWidth,
                      isSender: true,
                      scrollToMessage: scrollToMessage,
                      isSeen: this.isSeen,
                      pattern: pattern,
                      onUsernameClick: this.omUsernameClick,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
