import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

import 'message_wrapper.dart';

class ReceivedMessageBox extends StatelessWidget {
  final Message message;
  final MessageBrief? messageReplyBrief;
  final void Function(int, int) scrollToMessage;
  final void Function(String) onUsernameClick;
  final String? pattern;
  final void Function(String) onBotCommandClick;
  final void Function() onArrowIconClick;
  final void Function(TapDownDetails) storePosition;
  final bool isFirstMessageInGroupedMessages;
  final void Function() onEdit;

  const ReceivedMessageBox({
    Key? key,
    required this.message,
    required this.onBotCommandClick,
    required this.scrollToMessage,
    required this.onUsernameClick,
    required this.onArrowIconClick,
    required this.storePosition,
    required this.isFirstMessageInGroupedMessages,
    this.messageReplyBrief,
    this.pattern,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      messageReplyBrief: messageReplyBrief,
      maxWidth: maxWidthOfMessage(context),
      minWidth: minWidthOfMessage(context),
      onBotCommandClick: onBotCommandClick,
      isSender: false,
      scrollToMessage: scrollToMessage,
      pattern: pattern,
      isSeen: true,
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
            isSender: false,
            isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
          );
  }

  bool doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmoji(message);
  }
}
