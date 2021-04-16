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
        if (snapshot.hasData && snapshot.data != null) {
          int lastSeen = snapshot.data.messageId;
          int unreadCount = lastMessage.id - lastSeen;
          return (lastSeen < lastMessage.id)
              ? Padding(
                  padding: const EdgeInsets.only(
                    right: 5.0,
                    top: 2,
                  ),
                  child: Container(
                    width: unreadCount<10? 15: unreadCount<100?23:40,
                    height: 15,
                    child: Text("${unreadCount}",style: TextStyle(fontSize:11),),
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
