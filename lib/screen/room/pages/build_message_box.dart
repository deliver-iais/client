import 'dart:async';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver/screen/room/widgets/recieved_message_box.dart';
import 'package:deliver/screen/room/widgets/sended_message_box.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/ext_storage_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share/share.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:vibration/vibration.dart';
import 'package:process_run/shell.dart';

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
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _logger = GetIt.I.get<Logger>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _autRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

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
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (widget.selectMultiMessageSubject.stream.value) {
                    widget.addForwardMessage();
                  } else if (!isDesktop()) {
                    FocusScope.of(context).unfocus();
                    _showCustomMenu(context, msg);
                  }
                },
                onSecondaryTap: !isDesktop()
                    ? null
                    : () {
                        if (!widget.selectMultiMessageSubject.stream.value) {
                          _showCustomMenu(context, msg);
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
                child: Padding(
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
            _showCustomMenu(context, message);
          }
        },
        onSecondaryTap: !isDesktop()
            ? null
            : () {
                if (!widget.selectMultiMessageSubject.stream.value) {
                  _showCustomMenu(context, message);
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
        onArrowIconClick: () => _showCustomMenu(context, message, false),
        isSeen: message.id != null && message.id! <= widget.lastSeenMessageId,
        pattern: "",
        //todo add search message
        scrollToMessage: (int id) {
          _scrollToMessage(id: id);
        },
        omUsernameClick: onUsernameClick,
        storePosition: storePosition);

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
      onArrowIconClick: () => _showCustomMenu(context, message, false),
      storePosition: storePosition,
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
                child: CircleAvatarWidget(message.from.asUid(), 18,
                    isHeroEnabled: false),
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
      BuildContext context, Message message, bool isPersistentEventMessage) {
    this.showMenu(context: context, items: <PopupMenuEntry<OperationOnMessage>>[
      OperationOnMessageEntry(message,
          hasPermissionInChannel: widget.hasPermissionInChannel.value,
          hasPermissionInGroup: widget.hasPermissionInGroup,
          isPinned: widget.pinMessages.contains(message))
    ]);

    if (selectedValue == null) {
      return;
    }

    switch (selectedValue) {
      case OperationOnMessage.REPLY:
        widget.addReplyMessage();
        break;
      case OperationOnMessage.COPY:
        onCopy();
        break;
      case OperationOnMessage.FORWARD:
        onForward();
        break;
      case OperationOnMessage.DELETE:
        onDeleteMessage();
        break;
      case OperationOnMessage.EDIT:
        onEditMessage();
        break;
      case OperationOnMessage.SHARE:
        onShare();
        break;
      case OperationOnMessage.SAVE_TO_GALLERY:
        onSaveTOGallery();
        break;
      case OperationOnMessage.SAVE_TO_DOWNLOADS:
        onSaveTODownloads();
        break;
      case OperationOnMessage.SAVE_TO_MUSIC:
        onSaveToMusic();
        break;
      case OperationOnMessage.RESEND:
        onResend();
        break;
      case OperationOnMessage.DELETE_PENDING_MESSAGE:
        onDeletePendingMessage();
        break;
      case OperationOnMessage.PIN_MESSAGE:
        widget.onPin();
        break;
      case OperationOnMessage.UN_PIN_MESSAGE:
        widget.onUnPin();
        break;
      case OperationOnMessage.SHOW_IN_FOLDER:
        var path = await _fileRepo.getFileIfExist(
            widget.message.json!.toFile().uuid,
            widget.message.json!.toFile().name);
        if (path != null) onShowInFolder(path);
        break;
      case OperationOnMessage.REPORT:
        onReportMessage();
        break;
    }
  }

  onCopy() {
    if (widget.message.type == MessageType.TEXT) {
      Clipboard.setData(
          ClipboardData(text: widget.message.json!.toText().text));
    } else {
      Clipboard.setData(
          ClipboardData(text: widget.message.json!.toFile().caption));
    }
    ToastDisplay.showToast(
        toastText: _i18n.get("copied"), tostContext: context);
  }

  onForward() {
    _routingServices
        .openSelectForwardMessage(forwardedMessages: [widget.message]);
  }

  onEditMessage() {
    switch (widget.message.type) {
      case MessageType.TEXT:
        widget.onEdit();
        break;
      case MessageType.FILE:
        showCaptionDialog(
            roomUid: widget.message.roomUid.asUid(),
            editableMessage: widget.message,
            files: [],
            context: context);
        break;
      case MessageType.STICKER:
        // TODO: Handle this case.
        break;
      case MessageType.LOCATION:
        // TODO: Handle this case.
        break;
      case MessageType.LIVE_LOCATION:
        // TODO: Handle this case.
        break;
      case MessageType.POLL:
        // TODO: Handle this case.
        break;
      case MessageType.FORM:
        // TODO: Handle this case.
        break;
      case MessageType.PERSISTENT_EVENT:
        // TODO: Handle this case.
        break;
      case MessageType.NOT_SET:
        // TODO: Handle this case.
        break;
      case MessageType.BUTTONS:
        // TODO: Handle this case.
        break;
      case MessageType.SHARE_UID:
        // TODO: Handle this case.
        break;
      case MessageType.FORM_RESULT:
        // TODO: Handle this case.
        break;
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        // TODO: Handle this case.
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
  }

  onResend() {
    _messageRepo.resendMessage(widget.message);
  }

  onShare() async {
    try {
      String? result = await _fileRepo.getFileIfExist(
          widget.message.json!.toFile().uuid,
          widget.message.json!.toFile().name);
      if (result!.isNotEmpty) {
        Share.shareFiles([(result)],
            text: widget.message.json!.toFile().caption);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  onSaveTOGallery() {
    var file = widget.message.json!.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.pictures);
  }

  onSaveTODownloads() {
    var file = widget.message.json!.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.download);
  }

  onSaveToMusic() {
    var file = widget.message.json!.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.music);
  }

  onDeleteMessage() {
    showDeleteMsgDialog([widget.message], context, widget.onDelete,
        widget.currentRoom.lastMessageId ?? -1);
  }

  onDeletePendingMessage() {
    _messageRepo.deletePendingMessage(widget.message.packetId);
  }

  onReportMessage() {
    ToastDisplay.showToast(
        toastText: _i18n.get("report_message"), tostContext: context);
  }

  Future<void> onShowInFolder(path) async {
    var shell = Shell();
    if (isWindows()) {
      await shell.run('start "" "$path"');
    } else if (isLinux()) {
      await shell.run('nautilus $path');
    } else if (isMacOS()) {
      await shell.run('open $path');
    }
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
