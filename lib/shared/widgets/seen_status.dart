import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SeenStatus extends StatelessWidget {
  final Message message;
  final bool? isSeen;

  const SeenStatus(this.message, {Key? key, this.isSeen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SeenDao seenDao = GetIt.I.get<SeenDao>();
    final MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
    // Widget pendingMessage = Icon(Icons.access_alarm,
    //     color: ExtraTheme.of(context).seenStatus, size: 15);
    Widget pendingMessage = Container(
        // transform: Matrix4.translationValues(-1.0, 4.0, 0.0),
        child: Lottie.asset(
          'assets/animations/clock.json',
          width: 18,
          height: 18,
          // fit: BoxFit.fitHeight,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                const ['**'],
                value: ExtraTheme.of(context).seenStatus,
              ),
              ValueDelegate.transformScale(const ['**'],
                  value: const Offset(1.2, 1.2))
            ],
          ),
          repeat: true,
        ));

    if (message.id == null) {
      return FutureBuilder<PendingMessage?>(
          future: messageRepo.getPendingMessage(message.packetId),
          builder: ((c, pm) {
            if (pm.hasData && pm.data != null && pm.data!.failed) {
              return const Icon(Icons.warning, color: Colors.red, size: 15);
            } else {
              return pendingMessage;
            }
          }));
    } else if (isSeen != null && isSeen!) {
      return Icon(
        Icons.done_all,
        color: ExtraTheme.of(context).seenStatus,
        size: 15,
      );
    } else {
      return StreamBuilder<Seen?>(
        stream: seenDao.watchOthersSeen(message.roomUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Icon(
              snapshot.data!.messageId! >= message.id!
                  ? Icons.done_all
                  : Icons.done,
              color: ExtraTheme.of(context).seenStatus,
              size: 15,
            );
          } else {
            return Icon(
              Icons.done,
              color: ExtraTheme.of(context).seenStatus,
              size: 15,
            );
          }
        },
      );
    }
  }
}
