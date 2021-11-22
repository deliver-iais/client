import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/boxContent.dart';
import 'package:deliver/screen/room/widgets/message_wrapper.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final bool isSeen;
  final Function omUsernameClick;
  final String? pattern;

  const SentMessageBox(
      {Key? key,
      required this.message,
      required this.isSeen,
      required this.scrollToMessage,
      this.pattern,
      required this.omUsernameClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      isSender: true,
      scrollToMessage: scrollToMessage,
      isSeen: this.isSeen,
      pattern: pattern,
      onUsernameClick: this.omUsernameClick,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : MessageWrapper(child: boxContent, isSent: true);
  }

  doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmoji(message);
  }
}
