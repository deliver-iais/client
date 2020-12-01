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
  final Function scrollToMessage;

  const ReplyWidgetInMessage(
      {Key key, this.roomId, this.replyToId, this.scrollToMessage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
    MessageDao messageDao = GetIt.I.get<MessageDao>();
    return FutureBuilder<List<Message>>(
        future: messageDao.getMessageById(replyToId, roomId),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: accountRepo.currentUserUid.asString() ==
                                      snapshot.data[0].from
                                  ? ExtraTheme.of(context).secondColor
                                  : Theme.of(context).primaryColor,
                              width: 3))),
                  child: GestureDetector(
                    onTap: scrollToMessage(replyToId),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SenderAndContent(
                        messages: List<Message>.filled(1, snapshot.data[0]),
                        inBox: true,
                      ),
                    ),
                  )),
            );
          else
            return CircularProgressIndicator();
        });
  }
}
