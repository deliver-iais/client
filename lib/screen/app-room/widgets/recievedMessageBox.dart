import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecievedMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final bool isGroup;
  final Function scrollToMessage;
  final Function omUsernameClick;
  final String pattern;


  RecievedMessageBox(
      {Key key,
      this.message,
      this.maxWidth,
      this.isGroup,
      this.scrollToMessage,
      this.omUsernameClick,

      this.pattern})
      : super(key: key);
  final seenDao = GetIt.I.get<SeenDao>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Seen>(
        stream: seenDao.getByRoomIdandUserId(message.roomId, message.to),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.messageId < message.id) {
            seenDao.updateSeen(snapshot.data.copyWith(messageId: message.id));
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 5.0),
            child: message.type == MessageType.STICKER
                ? BoxContent(
                    message: message,
                    maxWidth: maxWidth,
                    isSender: false,
                    scrollToMessage: scrollToMessage,
                    onUsernameClick: this.omUsernameClick,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Container(
                      color: Theme.of(context).accentColor.withAlpha(60),
                      padding: const EdgeInsets.all(2),
                      child: BoxContent(
                        message: message,
                        maxWidth: maxWidth,
                        isSender: false,
                        scrollToMessage: scrollToMessage,
                        pattern: this.pattern,
                        onUsernameClick: this.omUsernameClick,
                      ),
                    ),
                  ),
          );
        });
  }
}
