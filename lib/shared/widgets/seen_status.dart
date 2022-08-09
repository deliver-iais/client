import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SeenStatus extends StatelessWidget {
  static final seenDao = GetIt.I.get<SeenDao>();
  static final messageRepo = GetIt.I.get<MessageRepo>();

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
    final theme = Theme.of(context);

    final color = iconColor ?? theme.primaryColor;
    const size = 16.0;
    final Widget pendingMessage = Container(
      child: Lottie.asset(
        'assets/animations/clock.json',
        width: 18,
        height: 18,
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

    return FutureBuilder<PendingMessage?>(
      future: messageRepo.getPendingMessage(messagePacketId),
      builder: ((c, pm) {
        if (pm.hasData && pm.data != null) {
          if (pm.data!.failed) {
            return Icon(
              Icons.warning,
              color: theme.colorScheme.error,
              size: 15,
            );
          } else {
            return pendingMessage;
          }
        } else if (messageId != null) {
          if (isSeen != null && isSeen!) {
            return Icon(
              Icons.done_all,
              color: color,
              size: size,
            );
          } else {
            return StreamBuilder<Seen?>(
              stream: seenDao.watchOthersSeen(roomUid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Icon(
                    snapshot.data!.messageId >= messageId!
                        ? Icons.done_all
                        : Icons.done,
                    color: color,
                    size: size,
                  );
                } else {
                  return Icon(
                    Icons.done,
                    color: color,
                    size: size,
                  );
                }
              },
            );
          }
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
