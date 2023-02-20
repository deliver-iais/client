import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageCounterWidget extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  final String roomUid;
  final int lastMessageId;
  final bool needBorder;

  const UnreadMessageCounterWidget(
    this.roomUid,
    this.lastMessageId, {
    this.needBorder = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Seen>(
      stream: _roomRepo.watchMySeen(roomUid),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.messageId > -1) {
          final lastSeen = snapshot.data?.messageId ?? 0;
          var unreadCount = lastMessageId - lastSeen;
          if (snapshot.data?.hiddenMessageCount != null) {
            unreadCount = unreadCount - snapshot.data!.hiddenMessageCount;
          }

          if (!snapshot.hasData) {
            unreadCount = 0;
          }

          return CircularCounterWidget(
            unreadCount: unreadCount,
            needBorder: needBorder,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
