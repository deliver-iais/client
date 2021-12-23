import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageCounterWidget extends StatelessWidget {
  final String roomUid;
  final int lastMessageId;
  final _roomRepo = GetIt.I.get<RoomRepo>();

  UnreadMessageCounterWidget(this.roomUid, this.lastMessageId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Seen?>(
      stream: _roomRepo.watchMySeen(roomUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int lastSeen = snapshot.data?.messageId ?? 0;
          int unreadCount = lastMessageId - lastSeen;
          if (snapshot.data?.hiddenMessageCount != null) {
            unreadCount = unreadCount - snapshot.data!.hiddenMessageCount!;
          }
          return (unreadCount > 0)
              ? Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    "${unreadCount >= 100 ? "+99" : unreadCount}",
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    // shape: BoxShape.circle,
                  ),
                )
              : const SizedBox.shrink();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
