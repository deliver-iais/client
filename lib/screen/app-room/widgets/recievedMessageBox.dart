import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';

class RecievedMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;

  const RecievedMessageBox({Key key, this.message, this.maxWidth})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!message.seen) {
      var messageDao = GetIt.I.get<MessageDao>();
      messageDao.updateMessage(message.copyWith(seen: true));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          color: ExtraTheme.of(context).secondColor,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: BoxContent(
              totalContent: message.content,
              msgType: message.type,
              maxWidth: maxWidth,
            ),
          ),
        ),
      ),
    );
  }
}
