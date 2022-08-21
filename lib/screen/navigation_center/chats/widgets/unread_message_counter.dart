import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageCounterWidget extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  final String roomUid;
  final int lastMessageId;

  const UnreadMessageCounterWidget(
    this.roomUid,
    this.lastMessageId, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

          return AnimatedScale(
            scale: unreadCount > 0 ? 1 : 0,
            duration: ANIMATION_DURATION,
            child: AnimatedOpacity(
              opacity: unreadCount > 0 ? 1 : 0,
              duration: ANIMATION_DURATION,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: unreadCount < 10
                    ? const EdgeInsets.all(2.0)
                    : const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 5.5,
                      ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: mainBorder,
                ),
                child: AnimatedSwitchWidget(
                  child: Text(
                    "${unreadCount <= 0 ? '' : unreadCount}",
                    key: ValueKey<int>(unreadCount),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
