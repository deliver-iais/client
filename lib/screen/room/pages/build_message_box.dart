import 'dart:async';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
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
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/widgets/recieved_message_box.dart';
import 'package:deliver/screen/room/widgets/sended_message_box.dart';
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
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:process_run/shell.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';

class BuildMessageBox extends StatefulWidget {
  final Message message;
  final MessageBrief? messageReplyBrief;
  final Message? messageBefore;
  final String roomId;
  final void Function(int, int) scrollToMessage;
  final void Function() onReply;
  final void Function() onEdit;
  final void Function() addForwardMessage;
  final void Function() onDelete;
  final void Function() onPin;
  final void Function() onUnPin;
  final bool menuDisabled;
  final int lastSeenMessageId;
  final List<Message> pinMessages;
  final bool hasPermissionInGroup;
  final BehaviorSubject<bool> hasPermissionInChannel;
  final BehaviorSubject<bool> selectMultiMessageSubject;

  const BuildMessageBox({
    Key? key,
    required this.message,
    this.messageBefore,
    required this.roomId,
    required this.scrollToMessage,
    required this.lastSeenMessageId,
    required this.onEdit,
    required this.onPin,
    required this.onUnPin,
    required this.onDelete,
    required this.pinMessages,
    required this.onReply,
    required this.selectMultiMessageSubject,
    required this.hasPermissionInGroup,
    required this.hasPermissionInChannel,
    required this.addForwardMessage,
    this.menuDisabled = false,
    this.messageReplyBrief,
  }) : super(key: key);

  @override
  State<BuildMessageBox> createState() => _BuildMessageBoxState();
}

class _BuildMessageBoxState extends State<BuildMessageBox>
    with CustomPopupMenu {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return _buildMessageBox(
      context,
      widget.message,
      widget.messageBefore,
      messageReplyBrief: widget.messageReplyBrief,
    );
  }

  Widget _buildMessageBox(
    BuildContext context,
    Message msg,
    Message? msgBefore, {
    MessageBrief? messageReplyBrief,
  }) {
    if (msg.isHidden) {
      return const SizedBox.shrink();
    }

    final isFirstMsgOfOnePerson = isFirstMessageOfOneDirection(msgBefore, msg);

    if (msg.type == MessageType.PERSISTENT_EVENT) {
      return _createPersistentEventMessageWidget(context, msg);
    } else if (msg.type == MessageType.CALL) {
      return _createCallMessageWidget(context, msg);
    } else {
      return _createSidedMessageWidget(
        context,
        msg,
        isFirstMsgOfOnePerson,
        messageReplyBrief: messageReplyBrief,
      );
    }
  }

  bool isFirstMessageOfOneDirection(Message? msgBefore, Message msg) {
    var isFirstMessageInGroupedMessages = true;

    if (msgBefore?.from == msg.from &&
        ((msgBefore?.time ?? 0) - msg.time).abs() < 1000 * 60 * 5) {
      final d1 = date(msgBefore?.time ?? 0);
      final d2 = date(msg.time);

      if (d1.day == d2.day && d1.month == d2.month && d1.year == d2.year) {
        if (!msgBefore!.isHidden && msgBefore.type != MessageType.CALL) {
          isFirstMessageInGroupedMessages = false;
        }
      }
    }
    return isFirstMessageInGroupedMessages;
  }

  Widget _createCallMessageWidget(BuildContext context, Message msg) {
    final theme = Theme.of(context);
    final colorsScheme = ExtraTheme.of(context).secondaryColorsScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: colorsScheme.primaryContainer,
            borderRadius: secondaryBorder,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: CallMessageWidget(
            message: widget.message,
            colorScheme: colorsScheme,
          ),
        )
      ],
    );
  }

  Widget _createPersistentEventMessageWidget(
    BuildContext context,
    Message msg,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
              vertical: msg.isHidden ? 0.0 : 4.0,
            ),
            child: PersistentEventMessage(
              message: msg,
              maxWidth: maxWidthOfMessage(context),
              onPinMessageClick: widget.scrollToMessage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _createSidedMessageWidget(
    BuildContext context,
    Message message,
    bool isFirstMessageInGroupedMessages, {
    MessageBrief? messageReplyBrief,
  }) {
    Widget messageWidget;

    if (_authRepo.isCurrentUser(message.from)) {
      messageWidget = showSentMessage(
        message,
        messageReplyBrief: messageReplyBrief,
        isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      );
    } else {
      messageWidget = showReceivedMessage(
        message,
        messageReplyBrief: messageReplyBrief,
        isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      );
    }

    // Wrap in Swipe widget if needed
    if (!widget.message.roomUid.asUid().isChannel()) {
      messageWidget = Swipe(
        onSwipeLeft: widget.onReply,
        child: Container(
          width: double.infinity,
          color: Colors.transparent,
          child: messageWidget,
        ),
      );
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
      child: messageWidget,
    );
  }

  Widget showSentMessage(
    Message message, {
    MessageBrief? messageReplyBrief,
    bool isFirstMessageInGroupedMessages = false,
  }) {
    final messageWidget = SentMessageBox(
      message: message,
      messageReplyBrief: messageReplyBrief,
      onArrowIconClick: () => _showCustomMenu(context, message),
      isSeen: message.id != null && message.id! <= widget.lastSeenMessageId,
      pattern: "",
      scrollToMessage: widget.scrollToMessage,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onUsernameClick: onUsernameClick,
      storePosition: storePosition,
      onEdit: widget.onEdit,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[messageWidget],
    );
  }

  void onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.roomId.asUid(), command);
  }

  Widget showReceivedMessage(
    Message message, {
    MessageBrief? messageReplyBrief,
    bool isFirstMessageInGroupedMessages = false,
  }) {
    final Widget messageWidget = ReceivedMessageBox(
      message: message,
      messageReplyBrief: messageReplyBrief,
      pattern: "",
      onBotCommandClick: onBotCommandClick,
      scrollToMessage: widget.scrollToMessage,
      onUsernameClick: onUsernameClick,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onArrowIconClick: () => _showCustomMenu(context, message),
      storePosition: storePosition,
      onEdit: widget.onEdit,
    );

    return Padding(
      padding: EdgeInsets.only(top: isFirstMessageInGroupedMessages ? 12.0 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isFirstMessageInGroupedMessages &&
              widget.message.roomUid.asUid().category == Categories.GROUP)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0, left: 8.0),
                  child: CircleAvatarWidget(
                    message.from.asUid(),
                    18,
                    isHeroEnabled: false,
                  ),
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

  Future<void> _showCustomMenu(
    BuildContext context,
    Message message,
  ) async {
    if (widget.menuDisabled) {
      return;
    }

    final selectedValue = await this.showMenu(
      context: context,
      items: <PopupMenuEntry<OperationOnMessage>>[
        OperationOnMessageEntry(
          message,
          hasPermissionInChannel: widget.hasPermissionInChannel.value,
          hasPermissionInGroup: widget.hasPermissionInGroup,
          isPinned: widget.pinMessages.contains(message),
        )
      ],
    );

    if (selectedValue == null) {
      return;
    }

    return OperationOnMessageSelection(
      message: widget.message,
      context: context,
      onDelete: widget.onDelete,
      onEdit: widget.onEdit,
      onPin: widget.onPin,
      onReply: widget.onReply,
      onUnPin: widget.onUnPin,
    ).selectOperation(selectedValue);
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

class OperationOnMessageSelection {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _logger = GetIt.I.get<Logger>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final void Function()? onReply;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final void Function()? onPin;
  final void Function()? onUnPin;
  final BuildContext context;
  final Message message;

  OperationOnMessageSelection({
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onPin,
    this.onUnPin,
    required this.context,
    required this.message,
  });

  Future<void> selectOperation(OperationOnMessage operationOnMessage) async {
    switch (operationOnMessage) {
      case OperationOnMessage.REPLY:
        onReply?.call();
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
        onShare().ignore();
        break;
      case OperationOnMessage.SAVE_TO_GALLERY:
        // ignore: use_build_context_synchronously
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
        onPin?.call();
        break;
      case OperationOnMessage.UN_PIN_MESSAGE:
        onUnPin?.call();
        break;
      case OperationOnMessage.SHOW_IN_FOLDER:
        final path = await _fileRepo.getFileIfExist(
          message.json.toFile().uuid,
          message.json.toFile().name,
        );
        if (path != null) onShowInFolder(path);
        break;
      case OperationOnMessage.REPORT:
        onReportMessage();
        break;
    }
  }

  void onCopy() {
    if (message.type == MessageType.TEXT) {
      Clipboard.setData(
        ClipboardData(
          text: synthesizeToOriginalWord(message.json.toText().text),
        ),
      );
    } else {
      Clipboard.setData(
        ClipboardData(
          text: synthesizeToOriginalWord(message.json.toFile().caption),
        ),
      );
    }
    ToastDisplay.showToast(
      toastText: _i18n.get("copied"),
      toastContext: context,
    );
  }

  void onForward() {
    _routingServices.openSelectForwardMessage(forwardedMessages: [message]);
  }

  void onEditMessage() {
    switch (message.type) {
      case MessageType.TEXT:
      case MessageType.FILE:
        onEdit?.call();
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
      case MessageType.TABLE:
      case MessageType.TRANSACTION:
        break;
    }
  }

  void onResend() {
    _messageRepo.resendMessage(message);
  }

  Future<void> onShare() async {
    if (message.type == MessageType.TEXT) {
      final copyText = await _roomRepo.getName(message.from.asUid()) +
          ":\n" +
          message.json.toText().text +
          "\n" +
          DateTime.fromMillisecondsSinceEpoch(
            message.time,
          ).toString().substring(0, 19);

      return Share.share(
        copyText,
      );
    } else {
      try {
        final result = await _fileRepo.getFileIfExist(
          message.json.toFile().uuid,
          message.json.toFile().name,
        );
        if (result!.isNotEmpty) {
          return Share.shareFiles(
            [(result)],
            text: message.json.toFile().caption,
          );
        }
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  void onSaveTOGallery(BuildContext context) {
    final file = message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.pictures);
    ToastDisplay.showToast(
      toastContext: context,
      toastText: _i18n.get("photo_saved"),
      isSaveToast: true,
    );
  }

  void onSaveTODownloads() {
    final file = message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.download);
    ToastDisplay.showToast(
      toastContext: context,
      toastText: _i18n.get("file_saved"),
      isSaveToast: true,
    );
  }

  void onSaveToMusic() {
    final file = message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.music);
    ToastDisplay.showToast(
      toastContext: context,
      toastText: _i18n.get("music_saved"),
      isSaveToast: true,
    );
  }

  void onDeleteMessage() {
    showDeleteMsgDialog(
      [message],
      context,
      onDelete ?? () {},
    );
  }

  void onDeletePendingMessage() {
    _messageRepo.deletePendingMessage(message.packetId);
  }

  void onReportMessage() {
    ToastDisplay.showToast(
      toastText: _i18n.get("report_message"),
      toastContext: context,
    );
  }

  void onShowInFolder(String path) {
    final shell = Shell();
    if (isWindows) {
      shell.run('explorer.exe /select,"${path.replaceAll("/", "\\")}"');
    } else if (isLinux) {
      shell.run('nautilus "$path"');
    } else if (isMacOS) {
      shell.run('open $path');
    }
  }
}
