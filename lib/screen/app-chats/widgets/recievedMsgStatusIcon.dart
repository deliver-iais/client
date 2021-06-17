import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageCounterWidget extends StatelessWidget {
  final Message lastMessage;

  UnreadMessageCounterWidget(this.lastMessage);

  int lastMessageId= 0;

  @override
  Widget build(BuildContext context) {
    final LastSeenDao lastSeenDao = GetIt.I.get<LastSeenDao>();
    return StreamBuilder<LastSeen>(
      stream: lastSeenDao.getByRoomIdAsStream(lastMessage.roomId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if(snapshot.data.messageId != null){
            int lastSeen = snapshot.data.messageId;
            int unreadCount = lastMessage.id - lastSeen;
            if(unreadCount>0){
              addUnreadMessageCount(lastMessage.roomId,lastMessage.id,unreadCount);
            }


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
          }else{
            return Padding(
              padding: const EdgeInsets.only(
                right: 5.0,
                top: 2,
              ),
              child: Container(
                width: lastMessage.id<10? 15: lastMessage.id<100?23:40,
                height: 15,
                child: Text("${lastMessage.id}",style: TextStyle(fontSize:11),),
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }

        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
