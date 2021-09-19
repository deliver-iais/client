import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageCounterWidget extends StatelessWidget {
  final String roomUid;
  final int lastMessageId;
  final _roomRepo = GetIt.I.get<RoomRepo>();

  UnreadMessageCounterWidget(this.roomUid, this.lastMessageId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Seen>(
      stream: _roomRepo.watchMySeen(roomUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int lastSeen = snapshot.data?.messageId ?? 0;
          int unreadCount = lastMessageId - lastSeen;
          return (unreadCount > 0)
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    "${unreadCount >= 100 ? "+99" : unreadCount}",
                    style: TextStyle(fontSize: 11),
                  ),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
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
