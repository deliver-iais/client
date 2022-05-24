import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:flutter/material.dart';

class SenderAndContent extends StatelessWidget {
  final Message? message;
  final MessageReplyBrief? messageReplyBrief;

  final bool expandContent;
  final Color? highlightColor;

  const SenderAndContent.message({
    Key? key,
    required this.message,
    this.expandContent = true,
    this.highlightColor,
    // ignore: avoid_field_initializers_in_const_classes
  })  : messageReplyBrief = null,
        super(key: key);

  const SenderAndContent.messageReplyBrief({
    Key? key,
    required this.messageReplyBrief,
    this.expandContent = true,
    this.highlightColor,
    // ignore: avoid_field_initializers_in_const_classes
  })  : message = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      return LastMessage(
        message: message,
        showSender: true,
        showSeenStatus: false,
        showRoomDetails: false,
        lastMessageId: 0,
        highlightColor: highlightColor,
        expandContent: expandContent,
      );
    } else {
      return LastMessage.messageReplyBrief(
        messageReplyBrief: messageReplyBrief,
        showSender: true,
        showSeenStatus: false,
        showRoomDetails: false,
        lastMessageId: 0,
        highlightColor: highlightColor,
        expandContent: expandContent,
      );
    }
  }
}
