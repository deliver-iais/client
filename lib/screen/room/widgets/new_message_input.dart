import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/widgets/input_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//TODO empty text click on arrow
class NewMessageInput extends StatelessWidget {
  final String currentRoomId;
  final int? replyMessageId;
  final Function? resetRoomPageDetails;
  final bool? waitingForForward;
  final Message? editableMessage;
  final Function? sendForwardMessage;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final Function? scrollToLastSentMessage;

  NewMessageInput(
      {Key? key,
      required this.currentRoomId,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.waitingForForward,
      this.editableMessage,
      this.sendForwardMessage,
      this.scrollToLastSentMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Room?>(
        stream: _roomRepo.watchRoom(currentRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Room currentRoom = snapshot.data!;
            return InputMessage(
                currentRoom: currentRoom,
                replyMessageId: replyMessageId,
                resetRoomPageDetails: resetRoomPageDetails,
                waitingForForward: waitingForForward!,
                editableMessage: editableMessage,
                sendForwardMessage: sendForwardMessage!,
                scrollToLastSentMessage: scrollToLastSentMessage!);
          } else {
            _roomRepo.createRoomIfNotExist(currentRoomId);
            return const SizedBox.shrink();
          }
        });
  }
}
