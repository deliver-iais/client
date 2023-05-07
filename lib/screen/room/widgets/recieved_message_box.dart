import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/screen/room/widgets/box_content.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:flutter/material.dart';

import 'markup/inline_markup_button_widget.dart';
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
  final bool showMenuDisable;
  final double width;

  const ReceivedMessageBox({
    super.key,
    required this.message,
    required this.onBotCommandClick,
    required this.scrollToMessage,
    required this.onUsernameClick,
    required this.onArrowIconClick,
    required this.storePosition,
    required this.width,
    required this.isFirstMessageInGroupedMessages,
    this.messageReplyBrief,
    this.pattern,
    required this.onEdit,
    this.showMenuDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    final boxContent = BoxContent(
      message: message,
      messageReplyBrief: messageReplyBrief,
      maxWidth: maxWidthOfMessage(width),
      minWidth: minWidthOfMessage(width),
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
      showMenuDisable: showMenuDisable,
    );

    return message.doNotNeedsWrapper()
        ? boxContent
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MessageWrapper(
                uid: message.from,
                isSender: false,
                isFirstMessageInGroupedMessages:
                    isFirstMessageInGroupedMessages,
                child: boxContent,
              ),
              if (message.markup?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12.0),
                  child: InlineMarkUpButtonWidget(
                    message: message,
                    isSender: false,
                  ),
                ),
            ],
          );
  }
}
