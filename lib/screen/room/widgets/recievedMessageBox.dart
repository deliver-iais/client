import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/boxContent.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

import 'message_wrapper.dart';

class ReceivedMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final Function onUsernameClick;
  final String pattern;
  final Function onBotCommandClick;

  ReceivedMessageBox(
      {Key key,
      this.message,
      this.onBotCommandClick,
      this.scrollToMessage,
      this.onUsernameClick,
      this.pattern})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      onBotCommandClick: onBotCommandClick,
      isSender: false,
      scrollToMessage: scrollToMessage,
      pattern: this.pattern,
      onUsernameClick: this.onUsernameClick,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : MessageWrapper(child: boxContent, isSent: false);
  }

  doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmoji(message);
  }
}
