import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

import 'message_wrapper.dart';

class ReceivedMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final Function onUsernameClick;
  final String? pattern;
  final Function onBotCommandClick;

  const ReceivedMessageBox(
      {Key? key,
      required this.message,
      required this.onBotCommandClick,
      required this.scrollToMessage,
      required this.onUsernameClick,
      this.pattern})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      minWidth: minWidthOfMessage(context),
      onBotCommandClick: onBotCommandClick,
      isSender: false,
      scrollToMessage: scrollToMessage,
      pattern: pattern,
      isSeen: true,
      onUsernameClick: onUsernameClick,
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
