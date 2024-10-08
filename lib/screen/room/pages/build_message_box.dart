import 'dart:async';

import 'package:clock/clock.dart';
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
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/link.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/animated_delete_widget.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';

class BuildMessageBox extends StatefulWidget {
  final Message message;
  final MessageBrief? messageReplyBrief;
  final Message? messageBefore;
  final Uid roomId;
  final void Function(int, int) scrollToMessage;
  final void Function() onReply;
  final void Function() onEdit;
  final void Function() onDelete;
  final void Function() onPin;
  final void Function() onUnPin;
  final bool menuDisabled;
  final double width;
  final int lastSeenMessageId;
  final String pattern;
  final List<Message> pinMessages;
  final bool hasPermissionInGroup;
  final BehaviorSubject<bool> hasPermissionInChannel;
  final BehaviorSubject<List<int>> selectedMessageListIndex;

  const BuildMessageBox({
    super.key,
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
    required this.selectedMessageListIndex,
    required this.hasPermissionInGroup,
    required this.width,
    required this.hasPermissionInChannel,
    this.menuDisabled = false,
    this.pattern = "",
    this.messageReplyBrief,
  });

  @override
  State<BuildMessageBox> createState() => _BuildMessageBoxState();
}

class _BuildMessageBoxState extends State<BuildMessageBox>
    with CustomPopupMenu {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  final animatedWidget = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    return AnimatedDeleteWidget(
      child: _buildMessageBox(
        context,
        widget.message,
        widget.messageBefore,
        messageReplyBrief: widget.messageReplyBrief,
      ),
    );
  }

  Widget _buildMessageBox(
    BuildContext context,
    Message msg,
    Message? msgBefore, {
    MessageBrief? messageReplyBrief,
  }) {
    final isFirstMsgOfOnePerson = isFirstMessageOfOneDirection(msgBefore, msg);
    if (msg.type == MessageType.PERSISTENT_EVENT) {
      return _createPersistentEventMessageWidget(context, msg);
    } else if (msg.type == MessageType.CALL) {
      return _createCallMessageWidget(context, msg);
    } else if (msg.type == MessageType.CALL_LOG) {
      return _createCallMessageWidget(context, msg, isCallLog: true);
    } else {
      return _createSidedMessageWidget(
        context,
        msg,
        isFirstMsgOfOnePerson,
        messageReplyBrief: messageReplyBrief,
      );
    }
  }

  void _addForwardMessage() {
    final smlIndex = widget.selectedMessageListIndex.value;
    smlIndex.contains(widget.message.id)
        ? smlIndex.remove(widget.message.id)
        : smlIndex.add(widget.message.id!);
    widget.selectedMessageListIndex.add(smlIndex);
  }

  bool isFirstMessageOfOneDirection(Message? msgBefore, Message msg) {
    var isFirstMessageInGroupedMessages = true;

    if (msgBefore?.from == msg.from &&
        ((msgBefore?.time ?? 0) - msg.time).abs() < 1000 * 60 * 5) {
      final d1 = date(msgBefore?.time ?? 0);
      final d2 = date(msg.time);

      if (d1.day == d2.day && d1.month == d2.month && d1.year == d2.year) {
        if (!msgBefore!.isHidden &&
            (msgBefore.type != MessageType.CALL ||
                msgBefore.type != MessageType.CALL_LOG)) {
          isFirstMessageInGroupedMessages = false;
        }
      }
    }
    return isFirstMessageInGroupedMessages;
  }

  Widget _createCallMessageWidget(
    BuildContext context,
    Message msg, {
    bool isCallLog = false,
  }) {
    final colorsScheme = ExtraTheme.of(context).secondaryColorsScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsetsDirectional.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: colorsScheme.primaryContainer,
            borderRadius: secondaryBorder,
            boxShadow: DEFAULT_BOX_SHADOWS,
          ),
          child: CallMessageWidget(
            message: widget.message,
            colorScheme: colorsScheme,
            isCallLog: isCallLog,
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
        _buildGestureDetector(
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: msg.isHidden ? 0.0 : p4,
            ),
            child: PersistentEventMessage(
              message: msg,
              maxWidth: maxWidthOfMessage(widget.width),
              onPinMessageClick: widget.scrollToMessage,
            ),
          ),
        )
      ],
    );
  }

  bool _hasPermissionToReply() =>
      !widget.roomId.isBroadcast() &&
      (!widget.roomId.isChannel() || widget.hasPermissionInChannel.value) &&
      !_selected();

  bool _hasPermissionForDoubleClickReply() =>
      isDesktopDevice && _hasPermissionToReply();

  Future<void> selectMessage() async {
    if (widget.message.id != null &&
        (await _messageRepo.getPendingEditedMessage(
              widget.message.roomUid,
              widget.message.id,
            ))
                ?.msg ==
            null) {
      _addForwardMessage();
    }
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
    if (!widget.message.roomUid.isChannel() && widget.message.id != null) {
      messageWidget = Swipe(
        onSwipeLeft: _hasPermissionToReply() ? widget.onReply : null,
        child: Container(
          width: double.infinity,
          color: Colors.transparent,
          child: messageWidget,
        ),
      );
    }
    return _buildGestureDetector(messageWidget);
  }

  bool _selected() => widget.selectedMessageListIndex.value.isNotEmpty;

  Widget _buildGestureDetector(Widget child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_selected()) {
            _addForwardMessage();
          } else if (!isDesktopDevice) {
            FocusScope.of(context).unfocus();
            _showCustomMenu();
          }
        },
        onSecondaryTap: () =>
            isDesktopDevice && !_selected() ? _showCustomMenu() : null,
        onDoubleTap:
            _hasPermissionForDoubleClickReply() ? widget.onReply : null,
        onLongPress: () async {
          await selectMessage();
        },
        onTapDown: storeTapDownPosition,
        onSecondaryTapDown: storeTapDownPosition,
        child: child,
      );

  Widget showSentMessage(
    Message message, {
    MessageBrief? messageReplyBrief,
    bool isFirstMessageInGroupedMessages = false,
  }) {
    final messageWidget = SentMessageBox(
      message: message,
      messageReplyBrief: messageReplyBrief,
      onArrowIconClick: _showCustomMenu,
      isSeen: message.id != null && message.id! <= widget.lastSeenMessageId,
      pattern: widget.pattern,
      scrollToMessage: widget.scrollToMessage,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onUsernameClick: onUsernameClick,
      storePosition: storeTapDownPosition,
      width: widget.width,
      onEdit: widget.onEdit,
      showMenuDisable: _selected(),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (shouldBeAnimated())
          StreamBuilder<bool>(
            stream: animatedWidget,
            initialData: shouldBeAnimated(),
            builder: (context, snapshot) {
              final isAnimated = snapshot.data ?? false;
              return AnimatedContainer(
                duration: AnimationSettings.slow,
                // transform: Matrix4.rotationX(turns.value * pi * 2),
                transform: isAnimated
                    ? Matrix4.translationValues(
                        -60,
                        80,
                        0,
                      )
                    : Matrix4.translationValues(
                        0,
                        0,
                        0,
                      ),
                transformAlignment: Alignment.center,
                child: messageWidget,
              );
            },
          )
        else
          messageWidget,
        _buildSelectedMessageStream(),
      ],
    );
  }

  Color getColor(Set<MaterialState> states) {
    const interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      // TODO(bitbeter): check later what was this
      return (Theme.of(context)).colorScheme.primary;
    }
    return (Theme.of(context)).colorScheme.primaryContainer;
  }

  @override
  void initState() {
    super.initState();
    if (shouldBeAnimated()) {
      animatedWidget.add(true);
      Timer(const Duration(milliseconds: 1), () {
        animatedWidget.add(false);
      });
    }
  }

  bool shouldBeAnimated() {
    var widgetSendTime = 0;
    try {
      widgetSendTime = int.parse(widget.message.packetId);
    } catch (_) {}
    return (clock.now().millisecondsSinceEpoch - widgetSendTime).abs() <
        AnimationSettings.slow.inMilliseconds * 3;
  }

  void onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.roomId, command);
  }

  Widget showReceivedMessage(
    Message message, {
    MessageBrief? messageReplyBrief,
    bool isFirstMessageInGroupedMessages = false,
  }) {
    final Widget messageWidget = ReceivedMessageBox(
      message: message,
      messageReplyBrief: messageReplyBrief,
      pattern: widget.pattern,
      onBotCommandClick: onBotCommandClick,
      scrollToMessage: widget.scrollToMessage,
      onUsernameClick: onUsernameClick,
      isFirstMessageInGroupedMessages: isFirstMessageInGroupedMessages,
      onArrowIconClick: _showCustomMenu,
      storePosition: storeTapDownPosition,
      onEdit: widget.onEdit,
      width: widget.width,
      showMenuDisable: _selected(),
    );

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: isFirstMessageInGroupedMessages ? p16 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (settings.showAvatars.value &&
              isFirstMessageInGroupedMessages &&
              widget.message.roomUid.category == Categories.GROUP)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: p8),
                  child: CircleAvatarWidget(
                    message.from,
                    18,
                    isHeroEnabled: false,
                  ),
                ),
                onTap: () {
                  _routingServices.openProfile(message.from.asString());
                },
              ),
            ),
          if (settings.showAvatars.value &&
              !isFirstMessageInGroupedMessages &&
              widget.message.roomUid.category == Categories.GROUP)
            const SizedBox(width: 44),
          messageWidget,
          const Spacer(),
          _buildSelectedMessageStream(),
        ],
      ),
    );
  }

  Widget _buildSelectedMessageStream() => StreamBuilder<List<int>>(
        stream: widget.selectedMessageListIndex,
        builder: (context, snapshot) {
          return AnimatedOpacity(
            duration: AnimationSettings.superSlow,
            opacity: snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty
                ? 1
                : 0,
            child: AnimatedContainer(
              width: snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty
                  ? SELECTED_MESSAGE_CHECKBOX_WIDTH
                  : 0,
              duration: AnimationSettings.superSlow,
              child: Checkbox(
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith(getColor),
                shape: const CircleBorder(),
                value: (snapshot.data ?? []).contains(widget.message.id),
                onChanged: (value) {
                  _addForwardMessage();
                },
              ),
            ),
          );
        },
      );

  Future<void> _showCustomMenu() async {
    if (widget.menuDisabled || _selected()) {
      return;
    }

    final selectedValue = await this.showMenu(
      context: context,
      items: <PopupMenuEntry<OperationOnMessage>>[
        OperationOnMessageEntry(
          widget.message,
          hasPermissionInChannel: widget.hasPermissionInChannel.value,
          hasPermissionInGroup: widget.hasPermissionInGroup,
          isPinned: widget.pinMessages.contains(widget.message),
        )
      ],
    );

    if (selectedValue == null) {
      return;
    }
    if (context.mounted) {
      return OperationOnMessageSelection(
        message: widget.message,
        context: context,
        onDelete: widget.onDelete,
        onEdit: widget.onEdit,
        onPin: widget.onPin,
        onReply: widget.onReply,
        onUnPin: widget.onUnPin,
        onSelect: selectMessage,
      ).selectOperation(selectedValue);
    }
  }

  Future<void> onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      final roomUid = "4:${username.substring(1)}";
      _routingServices.openRoom(roomUid.asUid());
    } else {
      _routingServices.openRoom(await _roomRepo.getUidById(username));
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
  final void Function()? onSelect;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final void Function()? onPin;
  final void Function()? onUnPin;
  final BuildContext context;
  final Message message;

  OperationOnMessageSelection({
    this.onReply,
    this.onSelect,
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
      case OperationOnMessage.SELECT:
        onSelect?.call();
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
        onSaveToGallery(context);
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
        await onDeletePendingMessage();
        break;
      case OperationOnMessage.DELETE_PENDING_EDITED_MESSAGE:
        onDeletePendingEditedMessage();
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
        );
        if (path != null) {
          onShowInFolder(path);
        }
        break;
      case OperationOnMessage.REPORT:
        onReportMessage();
        break;
      case OperationOnMessage.SAVE:
        onSave();
        break;
      case OperationOnMessage.SAVE_AS:
        onSaveAs();
        break;
    }
  }

  void onCopy() {
    if (message.type == MessageType.TEXT) {
      saveToClipboard(
        synthesizeToOriginalWord(message.json.toText().text),
      );
    } else if (message.type == MessageType.SHARE_UID) {
      final shareUid = message.json.toShareUid();
      saveToClipboard(
        buildMucInviteLink(shareUid.uid, shareUid.joinToken),
      );
    } else {
      saveToClipboard(
        synthesizeToOriginalWord(message.json.toFile().caption),
      );
    }
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
      case MessageType.CALL_LOG:
      case MessageType.TABLE:
      case MessageType.TRANSACTION:
      case MessageType.PAYMENT_INFORMATION:
    }
  }

  void onResend() {
    _messageRepo.resendMessage(message);
  }

  Future<void> onShare() async {
    if (message.type == MessageType.TEXT) {
      final timeText = DateTime.fromMillisecondsSinceEpoch(
        message.time,
      ).toString().substring(0, 19);

      final copyText =
          "${await _roomRepo.getName(message.from)}:\n${message.json.toText().text}\n$timeText";

      return Share.share(
        copyText,
      );
    } else {
      try {
        final result = await _fileRepo.getFileIfExist(
          message.json.toFile().uuid,
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

  void onSaveToGallery(BuildContext context) {
    final file = message.json.toFile();
    _fileRepo.saveFileInGallery(file.uuid, file.name);
    ToastDisplay.showToast(
      toastContext: context,
      toastText: _i18n.get("photo_saved"),
      showDoneAnimation: true,
    );
  }

  void onSaveTODownloads() {
    final file = message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.download);
    ToastDisplay.showToast(
      toastContext: context,
      toastText: _i18n.get("file_saved"),
      showDoneAnimation: true,
    );
  }

  void onSaveToMusic() {
    final file = message.json.toFile();
    _fileRepo.saveFileInDownloadDir(file.uuid, file.name, ExtStorage.music);
    ToastDisplay.showToast(
      toastContext: context,
      toastText: _i18n.get("music_saved"),
      showDoneAnimation: true,
    );
  }

  void onSave() {
    final file = message.json.toFile();
    _fileRepo.saveDownloadedFileInWeb(
      file.uuid,
      file.name,
    );
  }

  void onSaveAs() {
    final file = message.json.toFile();
    Future.delayed(const Duration(milliseconds: 350)).then((value) {
      FilePicker.platform
          .saveFile(
        lockParentWindow: true,
        dialogTitle: 'Save file',
        fileName: file.name,
      )
          .then((outputFile) {
        if (outputFile != null) {
          _fileRepo.saveFileToSpecifiedAddress(
            file.uuid,
            file.name,
            outputFile,
          );
        }
      });
    });
  }

  void onDeleteMessage() {
    showDeleteMsgDialog(
      [message],
      context,
      onDelete ?? () {},
    );
  }

  Future<void> onDeletePendingMessage() async {
    _messageRepo.deletePendingMessage(message.packetId);
    await _messageRepo.onDeletePendingMessage(message);
  }

  void onDeletePendingEditedMessage() {
    _messageRepo.deletePendingEditedMessage(message.roomUid, message.id);
    if (message.type == MessageType.FILE) {
      _fileRepo.cancelUploadFile(message.json.toFile().uuid);
    }
  }

  void onReportMessage() {
    ToastDisplay.showToast(
      toastText: _i18n.get("report_message"),
      toastContext: context,
    );
  }
}
