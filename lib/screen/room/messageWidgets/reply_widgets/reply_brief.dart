import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
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
          if (snapshot.hasData && snapshot.data != null)
            return Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
              child: Container(
                constraints: BoxConstraints.loose(Size.fromWidth(200)),
                padding: const EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: ExtraTheme.of(context).messageDetails,
                            width: 3))),
                child: SenderAndContent(
                  messages: [snapshot.data],
                ),
              ),
            );
          else
            return SizedBox(
              width: 200,
            );
        });
  }
}
