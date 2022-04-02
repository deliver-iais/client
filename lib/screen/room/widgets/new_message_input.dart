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
  final int replyMessageId;
  final void Function() resetRoomPageDetails;
  final bool waitingForForward;
  final Message? editableMessage;
  final void Function()? sendForwardMessage;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final void Function() scrollToLastSentMessage;
  final FocusNode focusNode;
  final TextEditingController textController;

  NewMessageInput({
    Key? key,
    required this.currentRoomId,
    required this.focusNode,
    required this.textController,
    required this.scrollToLastSentMessage,
    required this.resetRoomPageDetails,
    required this.waitingForForward,
    this.replyMessageId = 0,
    this.editableMessage,
    this.sendForwardMessage,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Room?>(
        stream: _roomRepo.watchRoom(currentRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final currentRoom = snapshot.data!;
            return InputMessage(
              currentRoom: currentRoom,
              replyMessageId: replyMessageId,
              resetRoomPageDetails: resetRoomPageDetails,
              waitingForForward: waitingForForward,
              editableMessage: editableMessage,
              sendForwardMessage: sendForwardMessage,
              scrollToLastSentMessage: scrollToLastSentMessage,
              focusNode: focusNode,
              textController: textController,
            );
          } else {
            _roomRepo.createRoomIfNotExist(currentRoomId);
            return const SizedBox.shrink();
          }
        });
  }
}
