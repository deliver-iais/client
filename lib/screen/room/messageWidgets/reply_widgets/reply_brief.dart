import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReplyBrief extends StatelessWidget {
  final String roomId;
  final int replyToId;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  ReplyBrief({
    Key key,
    this.roomId,
    this.replyToId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Message>(
        future: _messageRepo.getMessage(roomId, replyToId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                constraints: BoxConstraints.loose(Size.fromWidth(200)),
                padding: const EdgeInsets.only(left: 6.0),
                margin: const EdgeInsets.only(left: 2.0),
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                        width: 3,
                          color: Theme.of(context).primaryColor)),
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: SenderAndContent(
                  messages: [snapshot.data],
                ),
              ),
            );
          } else
            return SizedBox(
              width: 200,
            );
        });
  }
}
