import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/screen/room/widgets/input_message.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class NewMessageInput extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final Uid currentRoomId;
  final BehaviorSubject<Message?> replyMessageIdStream;
  final void Function() resetRoomPageDetails;
  final bool waitingForForward;
  final Message? editableMessage;
  final void Function()? sendForwardMessage;
  final void Function() scrollToLastSentMessage;
  final FocusNode focusNode;
  final void Function(
    int, {
    required bool ctrlIsPressed,
    required bool hasPermission,
  }) handleScrollToMessage;
  final void Function() deleteSelectedMessage;
  final InputMessageTextController textController;

  const NewMessageInput({
    super.key,
    required this.currentRoomId,
    required this.focusNode,
    required this.handleScrollToMessage,
    required this.textController,
    required this.scrollToLastSentMessage,
    required this.resetRoomPageDetails,
    required this.waitingForForward,
    required this.deleteSelectedMessage,
    required this.replyMessageIdStream,
    this.editableMessage,
    this.sendForwardMessage,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Room?>(
      stream: _roomRepo.watchRoom(currentRoomId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InputMessage(
            currentRoom: snapshot.data!,
            replyMessageIdStream: replyMessageIdStream,
            handleScrollToMessage: handleScrollToMessage,
            resetRoomPageDetails: resetRoomPageDetails,
            waitingForForward: waitingForForward,
            editableMessage: editableMessage,
            deleteSelectedMessage: deleteSelectedMessage,
            sendForwardMessage: sendForwardMessage,
            scrollToLastSentMessage: scrollToLastSentMessage,
            focusNode: focusNode,
            textController: textController,
          );
        } else {
          _roomRepo.createRoomIfNotExist(currentRoomId);
          return const SizedBox.shrink();
        }
      },
    );
  }
}
