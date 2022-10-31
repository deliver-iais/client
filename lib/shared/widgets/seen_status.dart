import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

enum SeenMessageStatus {
  PENDING,
  SENT,
  SEEN,
  FAILED,
}

class SeenStatus extends StatelessWidget {
  static final _seenDao = GetIt.I.get<SeenDao>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _cachingRepo = GetIt.I.get<CachingRepo>();

  final String roomUid;
  final String messagePacketId;
  final int? messageId;
  final bool? isSeen;
  final Color? iconColor;

  const SeenStatus(
    this.roomUid,
    this.messagePacketId, {
    super.key,
    this.messageId,
    this.isSeen,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return statusBuilder(context);
  }

  Widget statusBuilder(BuildContext context) {
    if (messageId == null || messageId == 0) {
      return FutureBuilder<PendingMessage?>(
        future: _messageRepo.getPendingMessage(messagePacketId),
        builder: ((c, pm) {
          if (pm.hasData && pm.data != null && pm.data!.failed) {
            return statusWidget(context, SeenMessageStatus.FAILED);
          } else {
            return statusWidget(context, SeenMessageStatus.PENDING);
          }
        }),
      );
    } else {
      if ((_cachingRepo.getLastSeenId(roomUid) ?? -1) >= messageId!) {
        return statusWidget(context, SeenMessageStatus.SEEN);
      }
      return FutureBuilder<PendingMessage?>(
        future: _messageRepo.getPendingEditedMessage(roomUid, messageId ?? 0),
        builder: ((c, pm) {
          if (pm.hasData) {
            if (pm.data?.failed ?? false) {
              return statusWidget(context, SeenMessageStatus.FAILED);
            } else {
              return statusWidget(context, SeenMessageStatus.PENDING);
            }
          } else if (isSeen != null && isSeen!) {
            return statusWidget(context, SeenMessageStatus.SEEN);
          } else {
            return StreamBuilder<Seen?>(
              stream: _seenDao.watchOthersSeen(roomUid).distinct(),
              builder: (context, snapshot) {
                // TODO(bitbeter): refactor this
                _cachingRepo.setLastSeenId(
                  roomUid,
                  snapshot.data?.messageId ?? -1,
                );
                final seen = (snapshot.data?.messageId ?? -1) >= messageId!;

                return AnimatedSwitcher(
                  duration: SLOW_ANIMATION_DURATION,
                  switchInCurve: Curves.easeIn,
                  child: Stack(
                    children: [
                      statusWidget(
                        context,
                        seen ? SeenMessageStatus.SEEN : SeenMessageStatus.SEEN,
                      )
                    ],
                  ),
                );
              },
            );
          }
        }),
      );
    }
  }

  Widget statusWidget(BuildContext context, SeenMessageStatus status) {
    final theme = Theme.of(context);

    final color = iconColor ?? theme.primaryColor;
    final errorColor = theme.colorScheme.error;
    const size = 14.5;

    switch (status) {
      case SeenMessageStatus.PENDING:
        return Container(
          key: const ValueKey("PENDING"),
          child: Lottie.asset(
            'assets/animations/clock.json',
            width: size,
            height: size,
            // fit: BoxFit.fitHeight,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.color(
                  const ['**'],
                  value: color,
                ),
                ValueDelegate.transformScale(
                  const ['**'],
                  value: const Offset(1.23, 1.23),
                )
              ],
            ),
            repeat: true,
          ),
        );
      case SeenMessageStatus.SENT:
        return Icon(
          key: const ValueKey("SENT"),
          Icons.done,
          color: color,
          size: size,
        );
      case SeenMessageStatus.SEEN:
        return Icon(
          key: const ValueKey("SEEN"),
          Icons.done_all,
          color: color,
          size: size,
        );
      case SeenMessageStatus.FAILED:
        return Icon(
          key: const ValueKey("FAILED"),
          Icons.priority_high_rounded,
          color: errorColor,
          size: size,
        );
    }
  }
}
