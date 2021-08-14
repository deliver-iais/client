import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/navigation_center/chats/widgets/lastMessage.dart';
import 'package:flutter/material.dart';

class SenderAndContent extends StatelessWidget {
  final List<Message> messages;

  SenderAndContent({Key key, this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.length <= 0) {
      return SizedBox.shrink();
    }

    return LastMessage(
      message: messages.first,
      hasMentioned: false,
      showSender: true,
      showSenderInSeparatedLine: true,
      showSeenStatus: false,
      lastMessageId: messages.first.id,
    );
  }
}
