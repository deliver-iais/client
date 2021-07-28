import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReplyWidgetInMessage extends StatelessWidget {
  final String roomId;
  final int replyToId;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  ReplyWidgetInMessage({
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
              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: ExtraTheme.of(context).messageDetails,
                            width: 3))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SenderAndContent(
                    messages: List<Message>.filled(1, snapshot.data),
                    inBox: true,
                  ),
                ),
              ),
            );
          else
            return SizedBox.shrink();
        });
  }
}
