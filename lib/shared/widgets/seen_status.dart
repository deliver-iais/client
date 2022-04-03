import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SeenStatus extends StatelessWidget {
  final Message message;
  final bool? isSeen;
  final Color? iconColor;

  const SeenStatus(this.message, {Key? key, this.isSeen, this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seenDao = GetIt.I.get<SeenDao>();
    final messageRepo = GetIt.I.get<MessageRepo>();
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

    if (message.id == null) {
      return FutureBuilder<PendingMessage?>(
        future: messageRepo.getPendingMessage(message.packetId),
        builder: ((c, pm) {
          if (pm.hasData && pm.data != null && pm.data!.failed) {
            return const Icon(Icons.warning, color: Colors.red, size: 15);
          } else {
            return pendingMessage;
          }
        }),
      );
    } else if (isSeen != null && isSeen!) {
      return Icon(
        Icons.done_all,
        color: color,
        size: size,
      );
    } else {
      return StreamBuilder<Seen?>(
        stream: seenDao.watchOthersSeen(message.roomUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Icon(
              snapshot.data!.messageId >= message.id!
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
}
