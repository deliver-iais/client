import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
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
    final theme = Theme.of(context);
    return StreamBuilder<Seen>(
      stream: _roomRepo.watchMySeen(roomUid),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.messageId >= 0) {
          int lastSeen = snapshot.data?.messageId ?? 0;
          int unreadCount = lastMessageId - lastSeen;
          if (snapshot.data?.hiddenMessageCount != null) {
            unreadCount = unreadCount - snapshot.data!.hiddenMessageCount!;
          }

          if (!snapshot.hasData) {
            unreadCount = 0;
          }

          return AnimatedScale(
              scale: unreadCount > 0 ? 1 : 0,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  "${unreadCount >= 100 ? "+99" : unreadCount}",
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimary,
                      height: 1.2),
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: mainBorder,
                ),
              ),
              duration: ANIMATION_DURATION * 0.5);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
