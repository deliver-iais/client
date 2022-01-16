import 'dart:async';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver/screen/room/widgets/recieved_message_box.dart';
import 'package:deliver/screen/room/widgets/sended_message_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:vibration/vibration.dart';

class BuildMessageBox extends StatefulWidget {
  final Message message;
  final Room currentRoom;
  final List<PendingMessage> pendingMessages;
  final ItemScrollController itemScrollController;
  final Function addReplyMessage;
  final Function onReply;
  final Function onEdit;
  final Function addForwardMessage;
  final Function onDelete;
  final Function onPin;
  final Function onUnPin;
  final Map<int, Message> selectedMessages;
  final int lastSeenMessageId;
  final List<Message> pinMessages;
  final int replyMessageId;
  final bool hasPermissionInGroup;
  final BehaviorSubject<bool> hasPermissionInChannel;
  final BehaviorSubject<bool> selectMultiMessageSubject;
  final Function changeReplyMessageId;

  const BuildMessageBox(
      {Key? key,
      required this.message,
      required this.currentRoom,
      required this.pendingMessages,
      required this.replyMessageId,
      required this.itemScrollController,
      required this.lastSeenMessageId,
      required this.addReplyMessage,
      required this.onEdit,
      required this.onPin,
      required this.onUnPin,
      required this.onDelete,
      required this.pinMessages,
      required this.onReply,
      required this.changeReplyMessageId,
      required this.selectMultiMessageSubject,
      required this.hasPermissionInGroup,
      required this.hasPermissionInChannel,
      required this.addForwardMessage,
      required this.selectedMessages})
      : super(key: key);

  @override
  State<BuildMessageBox> createState() => _BuildMessageBoxState();
}

class _BuildMessageBoxState extends State<BuildMessageBox>
    with CustomPopupMenu {
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return _buildMessageBox(
        context, widget.message, widget.currentRoom, widget.pendingMessages);
  }

  Widget _buildMessageBox(BuildContext context, Message msg, Room? currentRoom,
      List<PendingMessage> pendingMessages) {
    return msg.type != MessageType.PERSISTENT_EVENT
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: widget.selectedMessages.containsKey(msg.id) ||
                    (msg.id != null && msg.id == widget.replyMessageId)
                ? Theme.of(context).disabledColor
                : Colors.transparent,
            child: _createWidget(context, msg, currentRoom, pendingMessages),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: msg.json == "{}" ? 0.0 : 4.0),
                child: PersistentEventMessage(
                  message: msg,
                  maxWidth: maxWidthOfMessage(context),
                  onPinMessageClick: (int id) {
                    widget.changeReplyMessageId(id);
                    widget.itemScrollController.scrollTo(
                        alignment: .5,
                        curve: Curves.easeOut,
                        opacityAnimationWeights: [20, 20, 60],
                        index: id,
                        duration: const Duration(milliseconds: 1000));
                    Timer(const Duration(seconds: 1), () {
                      widget.changeReplyMessageId(-1);
                    });
                  },
                ),
              ),
            ],
          );
  }

  Widget _createWidget(BuildContext context, Message message, Room? currentRoom,
      List pendingMessages) {
    if (message.json == "{}") return const SizedBox.shrink();
    Widget messageWidget;
    if (_authRepo.isCurrentUser(message.from)) {
      messageWidget = showSentMessage(message);
    } else {
      messageWidget = showReceivedMessage(message);
    }
    var dismissibleWidget = SwipeTo(
        onLeftSwipe: () async {
          widget.addReplyMessage();
          Vibration.vibrate(duration: 150);
          //return false;
        },
        child: Container(
            width: double.infinity,
            color: Colors.transparent,
            child: messageWidget));

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (widget.selectMultiMessageSubject.stream.value) {
            widget.addForwardMessage();
          } else if (!isDesktop()) {
            FocusScope.of(context).unfocus();
            _showCustomMenu(context, message, false,this);
          }
        },
        onSecondaryTap: !isDesktop()
            ? null
            : () {
                if (!widget.selectMultiMessageSubject.stream.value) {
                  _showCustomMenu(context, message, false,this);
                }
              },
        onDoubleTap: !isDesktop() ? null : () => widget.onReply,
        onLongPress: () {
          if (!widget.selectMultiMessageSubject.stream.value) {
            widget.selectMultiMessageSubject.add(true);
          }
          widget.addForwardMessage();
        },
        onTapDown: storePosition,
        onSecondaryTapDown: storePosition,
        child: isDesktop()
            ? messageWidget
            : !widget.message.roomUid.asUid().isChannel()
                ? dismissibleWidget
                : StreamBuilder<bool>(
                    stream: widget.hasPermissionInChannel.stream,
                    builder: (c, hp) {
                      if (hp.hasData && hp.data!) {
                        return dismissibleWidget;
                      } else {
                        return messageWidget;
                      }
                    },
                  ));
  }

  Widget showSentMessage(Message message) {
    var messageWidget = SentMessageBox(
      message: message,
      onArrowIconClick: _showCustomMenu,
      isSeen: message.id != null && message.id! <= widget.lastSeenMessageId,
      pattern: "",
      //todo add search message
      scrollToMessage: (int id) {
        _scrollToMessage(id: id);
      },
      omUsernameClick: onUsernameClick,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[messageWidget],
    );
  }

  onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.currentRoom.uid.asUid(), command);
  }

  Widget showReceivedMessage(Message message) {
    var messageWidget = ReceivedMessageBox(
      message: message,
      pattern: "",
      onBotCommandClick: onBotCommandClick,
      scrollToMessage: (int id) => _scrollToMessage(id: id),
      onUsernameClick: onUsernameClick,
      onArrowIconClick: _showCustomMenu,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.message.roomUid.asUid().category == Categories.GROUP)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                child: CircleAvatarWidget(message.from.asUid(), 18, isHeroEnabled: false),
              ),
              onTap: () {
                _routingServices.openRoom(message.from);
              },
            ),
          ),
        messageWidget
      ],
    );
  }

  void _showCustomMenu(
      BuildContext context, Message message, bool isPersistentEventMessage,state) {
    state.showMenu(context: context, items: <PopupMenuEntry<OperationOnMessage>>[
      OperationOnMessageEntry(message,
          hasPermissionInChannel: widget.hasPermissionInChannel.value,
          hasPermissionInGroup: widget.hasPermissionInGroup,
          isPinned: widget.pinMessages.contains(message),
          roomLastMessageId: widget.currentRoom.lastMessageId!,
          onDelete: () => widget.onDelete(),
          onEdit: () => widget.onEdit(),
          onPin: () => widget.onPin(),
          onUnPin: () => widget.onUnPin(),
          onReply: () => widget.addReplyMessage())
    ]);
  }

  _scrollToMessage({required int id}) {
    widget.itemScrollController.scrollTo(
      index: id,
      duration: const Duration(microseconds: 1),
      alignment: .5,
      curve: Curves.easeOut,
      opacityAnimationWeights: [20, 20, 60],
    );
    if (id != -1) {
      widget.changeReplyMessageId(id);
    }
    if (widget.replyMessageId != -1) {
      Timer(const Duration(seconds: 3), () {
        widget.changeReplyMessageId(-1);
      });
    }
  }

  onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      String roomId = "4:${username.substring(1)}";
      _routingServices.openRoom(roomId);
    } else {
      String roomId = await _roomRepo.getUidById(username);
      _routingServices.openRoom(roomId);
    }
  }
}
