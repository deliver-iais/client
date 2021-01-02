import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/inputMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//TODO empty text click on arrow
class NewMessageInput extends StatelessWidget {
  final String currentRoomId;
  final int replyMessageId;
  final Function resetRoomPageDetails;
  final bool waitingForForward;
  final Function sendForwardMessage;
  final _roomDao = GetIt.I.get<RoomDao>();
  final Function showMentionList;

  NewMessageInput(
      {Key key,
      this.currentRoomId,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.waitingForForward,
      this.sendForwardMessage,
      this.showMentionList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<Room>(
        stream: roomDao.getByRoomId(currentRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Room currentRoom = snapshot.data;
            return InputMessage(
              currentRoom: currentRoom,
              replyMessageId: replyMessageId,
              resetRoomPageDetails: resetRoomPageDetails,
              waitingForForward: waitingForForward,
              sendForwardMessage: sendForwardMessage,
            );
          } else {
            _roomDao.insertRoom(Room(roomId: currentRoomId,));
            return SizedBox.shrink();
          }
        });
  }
}
