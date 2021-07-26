import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SeenStatus extends StatelessWidget {
  final Message message;
  final bool isSeen;

  const SeenStatus(this.message, {this.isSeen});

  @override
  Widget build(BuildContext context) {
    final SeenDao seenDao = GetIt.I.get<SeenDao>();
    final MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
    Widget pendingMessage = Icon(Icons.access_alarm,
        color: ExtraTheme.of(context).seenStatus, size: 15);

    if (message.id == null)
      return FutureBuilder<PendingMessage>(
          future: messageRepo.getPendingMessage(message.packetId),
          builder: ((c, pm) {
            if (pm.hasData && pm.data != null && pm.data.failed) {
              return Icon(Icons.warning, color: Colors.red, size: 15);
            } else {
              return pendingMessage;
            }
          }));
    else if (isSeen != null && isSeen) {
      return Icon(
        Icons.done_all,
        color: ExtraTheme.of(context).seenStatus,
        size: 15,
      );
    } else
      return StreamBuilder<Seen>(
        stream: seenDao.watchOthersSeen(message.roomUid),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Icon(
              snapshot.data.messageId >= message.id
                  ? Icons.done_all
                  : Icons.done,
              color: ExtraTheme.of(context).seenStatus,
              size: 15,
            );
          else
            return Icon(
              Icons.done,
              color: ExtraTheme.of(context).seenStatus,
              size: 15,
            );
        },
      );
  }
}
