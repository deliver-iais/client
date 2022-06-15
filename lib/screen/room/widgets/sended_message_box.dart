import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/screen/room/widgets/message_wrapper.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final MessageBrief? messageReplyBrief;
  final void Function(int, int) scrollToMessage;
  final bool isSeen;
  final bool isFirstMessageInGroupedMessages;
  final void Function(String) onUsernameClick;
  final String? pattern;
  final void Function() onArrowIconClick;
  final void Function(TapDownDetails) storePosition;
  final void Function() onEdit;

  const SentMessageBox({
    Key? key,
    required this.message,
    required this.messageReplyBrief,
    required this.isSeen,
    required this.isFirstMessageInGroupedMessages,
    required this.scrollToMessage,
    this.pattern,
    required this.onUsernameClick,
    required this.storePosition,
    required this.onArrowIconClick,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      messageReplyBrief: messageReplyBrief,
      maxWidth: maxWidthOfMessage(context),
      minWidth: minWidthOfMessage(context),
      isSender: true,
      scrollToMessage: scrollToMessage,
      onBotCommandClick: (str) => {},
      isSeen: isSeen,
      pattern: pattern,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onUsernameClick: onUsernameClick,
      onArrowIconClick: onArrowIconClick,
      storePosition: storePosition,
      onEdit: onEdit,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : MessageWrapper(
            uid: message.from,
            child: boxContent,
            isSender: true,
            isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
          );
  }

  bool doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmojiMessage(message);
  }
}
