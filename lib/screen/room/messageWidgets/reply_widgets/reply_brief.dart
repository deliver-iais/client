import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class ReplyBrief extends StatelessWidget {
  final String roomId;
  final int replyToId;
  final double maxWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final MessageBrief? messageReplyBrief;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  ReplyBrief({
    Key? key,
    required this.roomId,
    required this.replyToId,
    required this.maxWidth,
    required this.backgroundColor,
    required this.foregroundColor,
    this.messageReplyBrief,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.loose(Size.fromWidth(maxWidth - 14.0)),
      height: 50,
      padding: const EdgeInsets.only(left: 4.0, top: 4, bottom: 4, right: 8),
      margin: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: secondaryBorder,
      ),
      child: FutureBuilder<Message?>(
        future: _messageRepo.getMessage(roomId, replyToId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return repliedMessageBox(snapshot.data!);
          } else if (messageReplyBrief != null) {
            return repliedMessageBoxByMessageReplyBrief(messageReplyBrief!);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Row repliedMessageBox(Message message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.reply,
          size: 20,
          color: foregroundColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: SenderAndContent.message(
            message: message,
          ),
        ),
      ],
    );
  }

  Row repliedMessageBoxByMessageReplyBrief(
    MessageBrief messageReplyBrief,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.reply,
          size: 20,
          color: foregroundColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: SenderAndContent.messageReplyBrief(
            messageReplyBrief: messageReplyBrief,
          ),
        ),
      ],
    );
  }
}
