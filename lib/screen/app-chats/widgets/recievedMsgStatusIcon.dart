import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReceivedMsgIcon extends StatelessWidget {
  final Message lastMessage;

  const ReceivedMsgIcon(this.lastMessage);

  @override
  Widget build(BuildContext context) {
    final LastSeenDao lastSeenDao = GetIt.I.get<LastSeenDao>();
    return FutureBuilder<LastSeen>(
      future: lastSeenDao.getByRoomId(lastMessage.roomId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int lastSeen = snapshot.data.messageId ?? -1;
          return (lastSeen < lastMessage.id)
              ? Padding(
                  padding: const EdgeInsets.only(
                    right: 10.0,
                    top: 2,
                  ),
                  child: Container(
                    width: 10,
                    height: 10,
                    alignment: Alignment.center,
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
