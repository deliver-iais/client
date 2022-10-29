import 'dart:math';

import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

enum SeenMessageStatus {
  PENDING,
  SENT,
  SEEN,
  FAILED,
}

class SeenStatus extends StatelessWidget {
  static final seenDao = GetIt.I.get<SeenDao>();
  static final messageRepo = GetIt.I.get<MessageRepo>();

  final String roomUid;
  final String messagePacketId;
  final int? messageId;
  final bool? isSeen;
  final Color? iconColor;
  final _latestSeen = BehaviorSubject.seeded(false);

  SeenStatus(
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

  FutureBuilder<PendingMessage?> statusBuilder(BuildContext context) {
    if (messageId == null || messageId == 0) {
      return FutureBuilder<PendingMessage?>(
        key: const ValueKey("FutureBuilder_PENDING"),
        future: messageRepo.getPendingMessage(messagePacketId),
        builder: ((c, pm) {
          if (pm.hasData && pm.data != null && pm.data!.failed) {
            return statusWidget(context, SeenMessageStatus.FAILED);
          } else {
            return statusWidget(context, SeenMessageStatus.PENDING);
          }
        }),
      );
    } else {
      return FutureBuilder<PendingMessage?>(
        key: const ValueKey("FutureBuilder_PENDING_EDIT"),
        future: messageRepo.getPendingEditedMessage(roomUid, messageId ?? 0),
        builder: ((c, pm) {
          if (pm.hasData) {
            if (pm.data?.failed ?? false) {
              return statusWidget(context, SeenMessageStatus.FAILED);
            } else {
              return statusWidget(context, SeenMessageStatus.PENDING);
            }
          } else if (false && isSeen != null && isSeen!) {
            return statusWidget(context, SeenMessageStatus.SEEN);
          } else {
            return StreamBuilder<Seen?>(
              stream: seenDao.watchOthersSeen(roomUid).distinct(),
              builder: (context, snapshot) {
                print("$roomUid , $messageId , ${snapshot.data?.messageId}");
                _latestSeen.add(
                  (snapshot.data?.messageId ?? -1) >= messageId! ||
                      _latestSeen.value,
                );
                final seen = _latestSeen.value;
                return AnimatedSwitcher(
                  duration: SUPER_SLOW_ANIMATION_DURATION * 10,
                  child: statusWidget(
                    context,
                    seen ? SeenMessageStatus.SEEN : SeenMessageStatus.SENT,
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
    const size = 16.0;

    switch (status) {
      case SeenMessageStatus.PENDING:
        return Container(
          key: const ValueKey("PENDING"),
          child: Lottie.asset(
            'assets/animations/clock.json',
            width: size + 2,
            height: size + 2,
            // fit: BoxFit.fitHeight,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.color(
                  const ['**'],
                  value: color,
                ),
                ValueDelegate.transformScale(
                  const ['**'],
                  value: const Offset(1.2, 1.2),
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
