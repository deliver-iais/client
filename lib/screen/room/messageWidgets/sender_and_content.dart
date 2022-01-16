import 'package:deliver/box/message.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:flutter/material.dart';

class SenderAndContent extends StatelessWidget {
  final List<Message> messages;

  final bool expandContent;
  const SenderAndContent({Key? key, required this.messages, this.expandContent = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && messages.first.id == null) {
      return const SizedBox.shrink();
    }

    return LastMessage(
      message: messages.first,
      hasMentioned: false,
      showSender: true,
      showSenderInSeparatedLine: true,
      showSeenStatus: false,
      lastMessageId: messages.first.id!,
      expandContent: expandContent,
    );
  }
}
