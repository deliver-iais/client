import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SeenStatus extends StatelessWidget {
  final Message message;
  const SeenStatus(this.message);
  @override
  Widget build(BuildContext context) {
    final SeenDao seenDao = GetIt.I.get<SeenDao>();
    Widget pendingMessage = Icon(Icons.access_alarm,
        color: Theme.of(context).primaryColor, size: 15);
    if (message.id == null)
      return pendingMessage;
    else
      return FutureBuilder<bool>(
        future: seenDao.isSeenSentMessage(message),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Icon(
              (snapshot.data) ? Icons.done_all : Icons.done,
              color: ExtraTheme.of(context).text,
              size: 15,
            );
          else
            return pendingMessage;
        },
      );
  }
}
