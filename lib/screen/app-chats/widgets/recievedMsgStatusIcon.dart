import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReceivedMsgIcon extends StatelessWidget {
  final Message lastMessage;

  const ReceivedMsgIcon(this.lastMessage);

  @override
  Widget build(BuildContext context) {
    final SeenDao seenDao = GetIt.I.get<SeenDao>();
    return StreamBuilder<Seen>(
      stream:
          seenDao.getByRoomIdandUserId(lastMessage.roomId, lastMessage.from),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int lastSeen = snapshot.data.messageId ?? -1;
          return (lastSeen < lastMessage.id)
              ? Padding(
                  padding: const EdgeInsets.only(
                    right: 7.0,
                    top: 2,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: new BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : SizedBox.shrink();
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
