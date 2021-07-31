import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/screen/room/widgets/boxContent.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
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
    return message.type == MessageType.STICKER
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
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10))
                      .copyWith(bottomRight: Radius.zero),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 0.5,
                      offset: Offset(0, 0.5), // Shadow position
                    ),
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8))
                    .copyWith(bottomRight: Radius.zero),
                child: Container(
                  color: ExtraTheme.of(context).sentMessageBox,
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
          );
  }
}
