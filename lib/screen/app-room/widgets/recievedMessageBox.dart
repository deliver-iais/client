import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class RecievedMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final bool isGroup;

  const RecievedMessageBox({Key key, this.message, this.maxWidth,this.isGroup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var seenDao = GetIt.I.get<SeenDao>();
    return StreamBuilder<Seen>(
        stream: seenDao.getByRoomIdandUserId(message.roomId, message.to),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.messageId < message.id) {
            seenDao.updateSeen(snapshot.data.copyWith(messageId: message.id));
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0,left: 5.0,right: 3.0),
                child: CircleAvatarWidget(message.from.uid,18),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Container(
                    color: ExtraTheme.of(context).secondColor,
                    padding: const EdgeInsets.all(2),
                    child: BoxContent(message: message, maxWidth: maxWidth),
                  ),
                ),
              )
            ],
          );
        });
  }
}
