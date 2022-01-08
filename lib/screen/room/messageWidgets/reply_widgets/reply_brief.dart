import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReplyBrief extends StatelessWidget {
  final String roomId;
  final int replyToId;
  final double maxWidth;
  final Color color;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  ReplyBrief({
    Key? key,
    required this.roomId,
    required this.replyToId,
    required this.maxWidth,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Message?>(
        future: _messageRepo.getMessage(roomId, replyToId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                constraints:
                    BoxConstraints.loose(Size.fromWidth(maxWidth - 16.0)),
                padding: const EdgeInsets.only(
                    left: 4.0, top: 4, bottom: 4, right: 8),
                margin: const EdgeInsets.only(left: 2.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: SenderAndContent(
                        messages: [snapshot.data!],
                        expandContent: false,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox(
              width: 200,
            );
          }
        });
  }
}
