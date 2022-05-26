import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class SenderAndContent extends StatelessWidget {
  final Message? message;
  final MessageBrief? messageBrief;

  final bool expandContent;

  const SenderAndContent.message({
    Key? key,
    required this.message,
    this.expandContent = true,
    // ignore: avoid_field_initializers_in_const_classes
  })  : messageBrief = null,
        super(key: key);

  const SenderAndContent.messageBrief({
    Key? key,
    required this.messageBrief,
    this.expandContent = true,
    // ignore: avoid_field_initializers_in_const_classes
  })  : message = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      final colorScheme =
          ExtraTheme.of(context).messageColorScheme(message!.from);
      return LastMessage(
        message: message!,
        showSender: true,
        showSeenStatus: false,
        showRoomDetails: false,
        lastMessageId: 0,
        highlightColor: colorScheme.primary,
        expandContent: expandContent,
      );
    } else {
      final colorScheme =
          ExtraTheme.of(context).messageColorScheme(messageBrief!.from);
      return LastMessage.messageBrief(
        messageBrief: messageBrief!,
        showSender: true,
        showSeenStatus: false,
        showRoomDetails: false,
        lastMessageId: 0,
        highlightColor: colorScheme.primary,
        expandContent: expandContent,
      );
    }
  }
}
