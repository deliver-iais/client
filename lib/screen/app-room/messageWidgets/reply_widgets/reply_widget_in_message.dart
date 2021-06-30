import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/sender_and_content.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ReplyWidgetInMessage extends StatelessWidget {
  final String roomId;
  final int replyToId;

  const ReplyWidgetInMessage({
    Key key,
    this.roomId,
    this.replyToId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MessageDao messageDao = GetIt.I.get<MessageDao>();
    return FutureBuilder<List<Message>>(
        future: messageDao.getMessageById(replyToId, roomId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0)
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                          color:  ExtraTheme.of(context).messageDetails,
                            width: 3))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SenderAndContent(
                    messages: List<Message>.filled(1, snapshot.data[0]),
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
