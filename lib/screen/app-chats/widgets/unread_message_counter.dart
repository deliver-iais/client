import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageCounterWidget extends StatelessWidget {
  final Message lastMessage;

  UnreadMessageCounterWidget(this.lastMessage);

  @override
  Widget build(BuildContext context) {
    final lastSeenDao = GetIt.I.get<SeenDao>();
    return StreamBuilder<Seen>(
      stream: lastSeenDao.watchMySeen(lastMessage.roomUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int lastSeen = snapshot.data?.messageId ?? 0;
          int unreadCount = lastMessage.id - lastSeen;
          if (unreadCount > 0) {
            updateUnreadMessageCount(
                lastMessage.roomUid, lastMessage.id, unreadCount);
          } else
            eraseUnreadCountMessage(lastMessage.roomUid);
          return (unreadCount > 0)
              ? Padding(
                  padding: const EdgeInsets.only(
                    right: 5.0,
                    top: 2,
                  ),
                  child: Container(
                    width: unreadCount < 10
                        ? 15
                        : unreadCount < 100
                            ? 23
                            : 40,
                    height: 15,
                    child: Text(
                      "${unreadCount >= 100 ? "+99" : unreadCount}",
                      style: TextStyle(fontSize: 11),
                    ),
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
