import 'dart:async';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_message_widget.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/swipe_to_reply.dart';
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
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share/share.dart';
import 'package:process_run/shell.dart';

class BuildMessageBox extends StatefulWidget {
  final Message message;
  final Message? messageBefore;
  final String roomId;
  final ItemScrollController itemScrollController;
  final void Function() onReply;
  final void Function() onEdit;
  final void Function() addForwardMessage;
  final void Function() onDelete;
  final void Function() onPin;
  final void Function() onUnPin;
  final int lastSeenMessageId;
  final List<Message> pinMessages;
  final int replyMessageId;
  final bool hasPermissionInGroup;
  final BehaviorSubject<bool> hasPermissionInChannel;
  final BehaviorSubject<bool> selectMultiMessageSubject;
  final void Function(int) changeReplyMessageId;
  final Function resetRoomPageDetails;

  const BuildMessageBox(
      {Key? key,
      required this.message,
      this.messageBefore,
      required this.roomId,
      required this.replyMessageId,
      required this.itemScrollController,
      required this.lastSeenMessageId,
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
      required this.resetRoomPageDetails})
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
  static final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return _buildMessageBox(context, widget.message, widget.messageBefore);
  }

  Widget _buildMessageBox(
      BuildContext context, Message msg, Message? msgBefore) {
    if (msg.json.isEmptyMessage()) {
      return const SizedBox.shrink();
    }

    final isFirstMsgOfOnePerson = isFirstMessageOfOneDirection(msgBefore, msg);

    if (msg.type == MessageType.PERSISTENT_EVENT) {
      return _createPersistentEventMessageWidget(context, msg);
    } else if (msg.type == MessageType.CALL) {
      return _createCallMessageWidget(context, msg);
    } else {
      return _createSidedMessageWidget(context, msg, isFirstMsgOfOnePerson);
    }
  }

  bool isFirstMessageOfOneDirection(Message? msgBefore, Message msg) {
    var isFirstMessageInGroupedMessages = true;

    if (msgBefore?.from == msg.from &&
        ((msgBefore?.time ?? 0) - msg.time).abs() < 1000 * 60 * 5) {
      final d1 = date(msgBefore?.time ?? 0);
      final d2 = date(msg.time);

      if (d1.day == d2.day && d1.month == d2.month && d1.year == d2.year) {
        if (!msgBefore!.json.isEmptyMessage()) {
          isFirstMessageInGroupedMessages = false;
        }
      }
    }
    return isFirstMessageInGroupedMessages;
  }

  Widget _createCallMessageWidget(BuildContext context, Message msg) {
    final colorsScheme = ExtraTheme.of(context).secondaryColorsScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6, top: 4),
          decoration: BoxDecoration(
              color: colorsScheme.primaryContainer,
              borderRadius: secondaryBorder),
          child: CallMessageWidget(
            message: widget.message,
            colorScheme: colorsScheme,
          ),
        )
      ],
    );
  }

  Widget _createPersistentEventMessageWidget(
      BuildContext context, Message msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (widget.selectMultiMessageSubject.stream.value) {
              widget.addForwardMessage();
            } else if (!isDesktop) {
              FocusScope.of(context).unfocus();
              _showCustomMenu(context, msg);
            }
          },
          onSecondaryTap: !isDesktop
              ? null
              : () {
                  if (!widget.selectMultiMessageSubject.stream.value) {
                    _showCustomMenu(context, msg);
                  }
                },
          onDoubleTap: !isDesktop ? null : widget.onReply,
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
                vertical: msg.json == EMPTY_MESSAGE ? 0.0 : 4.0),
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

  Widget _createSidedMessageWidget(BuildContext context, Message message,
      bool isFirstMessageInGroupedMessages) {
    Widget messageWidget;

    if (_authRepo.isCurrentUser(message.from)) {
      messageWidget = showSentMessage(message, isFirstMessageInGroupedMessages);
    } else {
      messageWidget =
          showReceivedMessage(message, isFirstMessageInGroupedMessages);
    }

    // Wrap in Swipe widget if needed
    if (widget.message.roomUid.asUid().isChannel()) {
      messageWidget = Swipe(
          onSwipeLeft: widget.onReply,
          child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: messageWidget));
    }

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (widget.selectMultiMessageSubject.stream.value) {
            widget.addForwardMessage();
          } else if (!isDesktop) {
            FocusScope.of(context).unfocus();
            _showCustomMenu(context, message);
          }
        },
        onSecondaryTap: !isDesktop
            ? null
            : () {
                if (!widget.selectMultiMessageSubject.stream.value) {
                  _showCustomMenu(context, message);
                }
              },
        onDoubleTap: !isDesktop ? null : widget.onReply,
        onLongPress: () {
          if (!widget.selectMultiMessageSubject.stream.value) {
            widget.selectMultiMessageSubject.add(true);
          }
          widget.addForwardMessage();
        },
        onTapDown: storePosition,
        onSecondaryTapDown: storePosition,
        child: messageWidget);
  }

  Widget showSentMessage(
      Message message, bool isFirstMessageInGroupedMessages) {
    final messageWidget = SentMessageBox(
        message: message,
        onArrowIconClick: () => _showCustomMenu(context, message),
        isSeen: message.id != null && message.id! <= widget.lastSeenMessageId,
        pattern: "",
        //todo add search message
        scrollToMessage: (int id) {
          _scrollToMessage(id: id);
        },
        isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
        omUsernameClick: onUsernameClick,
        storePosition: storePosition);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[messageWidget],
    );
  }

  void onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.roomId.asUid(), command);
  }

  Widget senderNameBox(CustomColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 2, bottom: 2),
      child: FutureBuilder<String>(
        future: _roomRepo.getName(widget.message.from.asUid()),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return showName(colorScheme, snapshot.data!);
          } else {
            return const Text("");
          }
        },
      ),
    );
  }

  Widget showName(CustomColorScheme colorScheme, String name) {
    final minWidth = minWidthOfMessage(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          constraints: BoxConstraints.loose(Size.fromWidth(minWidth - 16)),
          child: Text(
            name.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
                inherit: true, fontSize: 13, color: colorScheme.primary),
          ),
        ),
        onTap: () {
          _routingServices.openProfile(widget.message.from);
        },
      ),
    );
  }

  Widget showReceivedMessage(
      Message message, bool isFirstMessageInGroupedMessages) {
    final CustomColorScheme colorScheme;
    if (message.type == MessageType.CALL &&
        (message.json.toCallEvent().newStatus == CallEvent_CallStatus.BUSY ||
            message.json.toCallEvent().newStatus ==
                CallEvent_CallStatus.DECLINED)) {
      colorScheme = ExtraTheme.of(context).messageColorScheme(message.to);
    } else {
      colorScheme = ExtraTheme.of(context).messageColorScheme(message.from);
    }

    Widget messageWidget = ReceivedMessageBox(
      message: message,
      pattern: "",
      colorScheme: colorScheme,
      onBotCommandClick: onBotCommandClick,
      scrollToMessage: (int id) => _scrollToMessage(id: id),
      onUsernameClick: onUsernameClick,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onArrowIconClick: () => _showCustomMenu(context, message),
      storePosition: storePosition,
    );

    if (isFirstMessageInGroupedMessages &&
        widget.message.roomUid.asUid().category == Categories.GROUP) {
      messageWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [senderNameBox(colorScheme), messageWidget]);
    }

    return Padding(
      padding: EdgeInsets.only(top: isFirstMessageInGroupedMessages ? 12.0 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isFirstMessageInGroupedMessages &&
              widget.message.roomUid.asUid().category == Categories.GROUP)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0, left: 8.0),
                  child: CircleAvatarWidget(message.from.asUid(), 18,
                      isHeroEnabled: false),
                ),
                onTap: () {
                  _routingServices.openProfile(message.from);
                },
              ),
            ),
          if (!isFirstMessageInGroupedMessages &&
              widget.message.roomUid.asUid().category == Categories.GROUP)
            const SizedBox(width: 44),
          messageWidget
        ],
      ),
    );
  }

  void _showCustomMenu(
    BuildContext context,
    Message message,
  ) async {
    final selectedValue = await this
        .showMenu(context: context, items: <PopupMenuEntry<OperationOnMessage>>[
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
        widget.onReply();
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
        onSaveTOGallery(context);
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
        final path = await _fileRepo.getFileIfExist(
            widget.message.json.toFile().uuid,
            widget.message.json.toFile().name);
        if (path != null) onShowInFolder(path);
        break;
      case OperationOnMessage.REPORT:
        onReportMessage();
        break;
    }
  }

  void onCopy() {
    if (widget.message.type == MessageType.TEXT) {
      Clipboard.setData(ClipboardData(text: widget.message.json.toText().text));
    } else {
      Clipboard.setData(
          ClipboardData(text: widget.message.json.toFile().caption));
    }
    ToastDisplay.showToast(
        toastText: _i18n.get("copied"), toastContext: context);
  }

  void onForward() {
    _routingServices
        .openSelectForwardMessage(forwardedMessages: [widget.message]);
  }

  void onEditMessage() {
    switch (widget.message.type) {
      case MessageType.TEXT:
        widget.onEdit();
        break;
      case MessageType.FILE:
        showCaptionDialog(
            replyMessageId: widget.replyMessageId,
            resetRoomPageDetails: widget.resetRoomPageDetails,
            roomUid: widget.message.roomUid.asUid(),
            editableMessage: widget.message,
            files: [],
            context: context);
        break;
      case MessageType.STICKER:
      case MessageType.LOCATION:
      case MessageType.LIVE_LOCATION:
      case MessageType.POLL:
      case MessageType.FORM:
      case MessageType.PERSISTENT_EVENT:
      case MessageType.NOT_SET:
      case MessageType.BUTTONS:
      case MessageType.SHARE_UID:
      case MessageType.FORM_RESULT:
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
      case MessageType.CALL:
      case MessageType.Table:
        // TODO: Handle these cases.
        break;
    }
  }

  void onResend() {
    _messageRepo.resendMessage(widget.message);
  }

  Future<void> onShare() async {
    try {
      final result = await _fileRepo.getFileIfExist(
          widget.message.json.toFile().uuid, widget.message.json.toFile().name);
      if (result!.isNotEmpty) {
        Share.shareFiles([(result)],
            text: widget.message.json.toFile().caption);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void onSaveTOGallery(BuildContext context) {
    final file = widget.message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.pictures);
    ToastDisplay.showToast(
        toastContext: context,
        toastText: _i18n.get("photo_saved"),
        isSaveToast: true);
  }

  void onSaveTODownloads() {
    final file = widget.message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.download);
    ToastDisplay.showToast(
        toastContext: context,
        toastText: _i18n.get("file_saved"),
        isSaveToast: true);
  }

  void onSaveToMusic() {
    final file = widget.message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.music);
    ToastDisplay.showToast(
        toastContext: context,
        toastText: _i18n.get("music_saved"),
        isSaveToast: true);
  }

  void onDeleteMessage() {
    showDeleteMsgDialog(
      [widget.message],
      context,
      widget.onDelete,
    );
  }

  void onDeletePendingMessage() {
    _messageRepo.deletePendingMessage(widget.message.packetId);
  }

  void onReportMessage() {
    ToastDisplay.showToast(
        toastText: _i18n.get("report_message"), toastContext: context);
  }

  Future<void> onShowInFolder(String path) async {
    final shell = Shell();
    if (isWindows) {
      await shell.run('start "" "$path"');
    } else if (isLinux) {
      await shell.run('nautilus $path');
    } else if (isMacOS) {
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

  Future<void> onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      final roomId = "4:${username.substring(1)}";
      _routingServices.openRoom(roomId);
    } else {
      final roomId = await _roomRepo.getUidById(username);
      _routingServices.openRoom(roomId);
    }
  }
}
