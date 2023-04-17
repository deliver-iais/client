import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/animation_emoji.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/screen/room/widgets/markup/inline_markup_button_widget.dart';
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
  final bool showMenuDisable;
  final double width;

  const SentMessageBox({
    super.key,
    required this.message,
    required this.messageReplyBrief,
    required this.isSeen,
    required this.isFirstMessageInGroupedMessages,
    required this.scrollToMessage,
    required this.onUsernameClick,
    required this.storePosition,
    required this.onArrowIconClick,
    required this.width,
    required this.onEdit,
    this.pattern,
    this.showMenuDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      messageReplyBrief: messageReplyBrief,
      maxWidth: maxWidthOfMessage(width),
      minWidth: minWidthOfMessage(width),
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
      showMenuDisable: showMenuDisable,
    );

    return doNotNeedsWrapper()
        ? boxContent
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MessageWrapper(
                uid: message.from,
                isSender: true,
                isFirstMessageInGroupedMessages:
                    isFirstMessageInGroupedMessages,
                child: boxContent,
              ),
              if (message.markup?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12.0),
                  child: InlineMarkUpButtonWidget(
                    message: message,
                    isSender: true,
                  ),
                ),
            ],
          );
  }

  bool doNotNeedsWrapper() {
    return message.type == MessageType.STICKER || isOnlyEmojiMessage(message);
  }
}
