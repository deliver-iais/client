import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/recievedMsgStatusIcon.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'contactPic.dart';
import 'lastMessage.dart';

class ChatItem extends StatelessWidget {
  final RoomWithMessage roomWithMessage;

  final AccountRepo accountRepo = GetIt.I.get<AccountRepo>();

  ChatItem({this.roomWithMessage});



  @override
  Widget build(BuildContext context) {
    var messageType = roomWithMessage.lastMessage.from
            .isSameEntity(accountRepo.currentUserUid)
        ? "send"
        : "recieve";

    var maxWidth = MediaQuery.of(context).size.width - 36 - 16 - 32;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            ContactPic(true, roomWithMessage.room.roomId.uid),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    roomWithMessage.room.roomId,
                    style: TextStyle(
                      color: ExtraTheme.of(context).infoChat,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                   Row(
                     children: <Widget>[
                       messageType == "send"
                           ? SeenStatus(roomWithMessage.lastMessage)
                           : Container(),
                       Padding(
                           padding: const EdgeInsets.only(
                             top: 3.0,
                           ),
                           child: LastMessage(
                               message: roomWithMessage.lastMessage)),
                     ],
                   ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4.0,
                    ),
                    child: Text(
                      roomWithMessage.lastMessage.time.dateTimeFormat(),
                      maxLines: 1,
                      style: TextStyle(
                        color: ExtraTheme.of(context).details,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  roomWithMessage.room.mentioned != false
                      ? Padding(
                    padding: const EdgeInsets.only(
                      right: 3.0,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 15,
                          height: 15,
                          decoration: new BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Positioned(
                          top: 2.25,
                          right: 2.25,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: new BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            width: 6.5,
                            height: 6.5,
                            decoration: new BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : messageType == "recieve"
                      ? ReceivedMsgIcon(roomWithMessage.lastMessage)
                      : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
