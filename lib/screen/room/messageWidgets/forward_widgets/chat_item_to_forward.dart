import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../box/message.dart';
import '../../../../shared/constants.dart';
import '../../../../shared/methods/time.dart';
import '../../../../shared/widgets/seen_status.dart';

class ChatItemToForward extends StatelessWidget {
  final Room room;
  final void Function(Uid) onTap;
  final void Function(Uid) onLongPressed;
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  final bool isSelected;

  const ChatItemToForward(
      {super.key,
      required this.room,
      required this.onTap,
      required this.onLongPressed,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        onLongPressed(room.uid);
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 12,
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                color: Theme.of(context).colorScheme.primary,
                size: 60,
              )
            else
              CircleAvatarWidget(room.uid, 30,
                  showSavedMessageLogoIfNeeded: true),
            // ContactPic(true, uid),
            const SizedBox(
              width: 12,
            ),
            Flexible(
              child: FutureBuilder<String>(
                future: _roomRepo.getName(room.uid,
                    forceToReturnSavedMessage: true),
                builder: (c, snaps) {
                  if (snaps.hasData && snaps.data != null) {
                    return Text(
                      snaps.data!,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    );
                  } else {
                    return const Text(
                      "",
                      style: TextStyle(fontSize: 18),
                    );
                  }
                },
              ),
            ),

          ],

        ),
      ),
      onTap: () => onTap(room.uid),
    );
  }

  List<Widget> buildLastMessageTimeAndSeenStatus(Message message) {
    return [
      if (GetIt.I.get<AuthRepo>().isCurrentUser(message.from))
        Padding(
          padding: const EdgeInsets.all(p4),
          child: SeenStatus(
            message.roomUid,
            message.packetId,
            messageId: message.id,
          ),
        ),
      Text(
        dateTimeFromNowFormat(
          date(message.time),
          summery: true,
        ),
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 11,
        ),
        textDirection: GetIt.I.get<I18N>().defaultTextDirection,
      ),
    ];
  }
}
