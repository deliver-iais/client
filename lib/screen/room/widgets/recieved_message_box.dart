import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

import 'message_wrapper.dart';

class ReceivedMessageBox extends StatelessWidget {
  final Message message;
  final Function scrollToMessage;
  final Function onUsernameClick;
  final String? pattern;
  final Function onBotCommandClick;
  final Function onArrowIconClick;
  final void Function(TapDownDetails) storePosition;
  final bool isFirstMessageInGroupedMessages;

  const ReceivedMessageBox(
      {Key? key,
      required this.message,
      required this.onBotCommandClick,
      required this.scrollToMessage,
      required this.onUsernameClick,
      required this.onArrowIconClick,
      required this.storePosition,
      required this.isFirstMessageInGroupedMessages,
      this.pattern})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ExtraTheme.of(context).messageColorScheme(message.from);

    final boxContent = BoxContent(
      message: message,
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
      colorScheme: colorScheme,
      storePosition: storePosition,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : MessageWrapper(
            uid: message.from,
            colorScheme: colorScheme,
            child: boxContent,
            isSender: false,
            isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages);
  }

  doNotNeedsWrapper() {
    return message.type == MessageType.STICKER ||
        AnimatedEmoji.isAnimatedEmoji(message);
  }
}
