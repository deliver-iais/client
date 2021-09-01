import 'package:we/box/room.dart';
import 'package:we/repository/roomRepo.dart';
import 'package:we/screen/room/widgets/inputMessage.dart';
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
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final Function scrollToLastSentMessage;

  NewMessageInput(
      {Key key,
      this.currentRoomId,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.waitingForForward,
      this.sendForwardMessage,
      this.scrollToLastSentMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Room>(
        stream: _roomRepo.watchRoom(currentRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Room currentRoom = snapshot.data;
            return InputMessage(
                currentRoom: currentRoom,
                replyMessageId: replyMessageId,
                resetRoomPageDetails: resetRoomPageDetails,
                waitingForForward: waitingForForward,
                sendForwardMessage: sendForwardMessage,
                scrollToLastSentMessage: scrollToLastSentMessage);
          } else {
            _roomRepo.createRoomIfNotExist(currentRoomId);
            return SizedBox.shrink();
          }
        });
  }
}
