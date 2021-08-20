import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/sender_and_content.dart';
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
              padding: const EdgeInsets.all(2),
              child: Container(
                constraints: BoxConstraints.loose(Size.fromWidth(200)),
                padding: const EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment(1, 0.0),
                    colors: <Color>[
                      Theme.of(context).dividerColor.withAlpha(45),
                      Color(0x11ffffff)
                    ],
                    tileMode: TileMode.repeated,
                  ),
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color(0x22ffffff)
                          : Color(0x11000000)),
                  borderRadius: BorderRadius.circular(10),
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
