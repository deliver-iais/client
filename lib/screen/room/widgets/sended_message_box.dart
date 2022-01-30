import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/screen/room/widgets/message_wrapper.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final bool isSeen;
  final bool isFirstMessageInGroupedMessages;
  final Function omUsernameClick;
  final String? pattern;
  final Function onArrowIconClick;
  final void Function(TapDownDetails) storePosition;

  const SentMessageBox(
      {Key? key,
      required this.message,
      required this.isSeen,
      required this.isFirstMessageInGroupedMessages,
      required this.scrollToMessage,
      this.pattern,
      required this.omUsernameClick,
      required this.storePosition,
      required this.onArrowIconClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      maxWidth: maxWidthOfMessage(context),
      minWidth: minWidthOfMessage(context),
      isSender: true,
      scrollToMessage: scrollToMessage,
      isSeen: isSeen,
      pattern: pattern,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onUsernameClick: omUsernameClick,
      onArrowIconClick: onArrowIconClick,
      storePosition: storePosition,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : MessageWrapper(
            child: boxContent, isSender: true, isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages);
  }

  doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmoji(message);
  }
}
