import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/ext_storage_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:process_run/shell.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';

class OperationOnMessageEntry extends PopupMenuEntry<OperationOnMessage> {
  final Message message;
  final bool hasPermissionInChannel;
  final bool hasPermissionInGroup;
  final bool isPinned;
  final int roomLastMessageId;
  final void Function() onDelete;
  final void Function() onEdit;
  final void Function() onPin;
  final void Function() onUnPin;
  final void Function() onReply;

  const OperationOnMessageEntry(
    this.message, {
    Key? key,
    this.hasPermissionInChannel = true,
    this.hasPermissionInGroup = true,
    this.isPinned = false,
    required this.onEdit,
    required this.onPin,
    required this.onUnPin,
    required this.onReply,
    this.onDelete = empty,
    this.roomLastMessageId = 1,
  }) : super(key: key);

  static empty() {}

  @override
  OperationOnMessageEntryState createState() => OperationOnMessageEntryState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnMessage? value) =>
      value == OperationOnMessage.REPLY;
}

class OperationOnMessageEntryState extends State<OperationOnMessageEntry> {
  static final _logger = GetIt.I.get<Logger>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _autRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingServices = GetIt.I.get<RoutingService>();

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
            text: widget.message.json!.toFile().caption.isNotEmpty
                ? widget.message.json!.toFile().caption
                : 'Deliver');
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
    showDeleteMsgDialog(
        [widget.message], context, widget.onDelete, widget.roomLastMessageId);
  }

  onDeletePendingMessage() {
    _messageRepo.deletePendingMessage(widget.message.packetId);
  }

  onReportMessage() {
    ToastDisplay.showToast(
        toastText: _i18n.get("report_message"), tostContext: context);
  }

  Future<void> onShowInFolder(
      AsyncSnapshot<dynamic> snapshot, BuildContext context) async {
    var shell = Shell();
    if (isWindows()) {
      await shell.run('start "" "${snapshot.data.parent.path}"');
    } else if (isLinux()) {
      await shell.run('nautilus ${snapshot.data.path}');
    } else if (isMacOS()) {
      await shell.run('open ${snapshot.data.parent.path}');
    }
  }

  final BehaviorSubject<bool> _fileIsExist = BehaviorSubject.seeded(false);
  bool _hasPermissionToDeleteMsg = false;

  @override
  void initState() {
    _hasPermissionToDeleteMsg = widget.message.id == null ||
        _autRepo.isCurrentUserSender(widget.message) ||
        (widget.message.roomUid.isChannel() && widget.hasPermissionInChannel) ||
        (widget.message.roomUid.isGroup() && widget.hasPermissionInGroup);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        size: (PopupMenuTheme.of(context).textStyle?.fontSize ?? 20) + 4,
        color: PopupMenuTheme.of(context).textStyle?.color,
      ),
      child: Column(
        children: [
          if (widget.hasPermissionInChannel && widget.message.id != null)
            PopupMenuItem(
              onTap: widget.onReply,
              child: Row(children: [
                const Icon(Icons.reply),
                const SizedBox(width: 8),
                Text(_i18n.get("Reply")),
              ]),
            ),
          if ((widget.message.roomUid.asUid().category == Categories.GROUP &&
                  widget.hasPermissionInGroup) ||
              (widget.message.roomUid.asUid().category == Categories.CHANNEL &&
                  widget.hasPermissionInChannel))
            if (!widget.isPinned)
              PopupMenuItem(
                  onTap: widget.onPin,
                  child: Row(children: [
                    const Icon(Icons.push_pin_outlined),
                    const SizedBox(width: 8),
                    Text(_i18n.get("pin")),
                  ]))
            else
              PopupMenuItem(
                  onTap: widget.onUnPin,
                  child: Row(children: [
                    const Icon(Icons.remove),
                    const SizedBox(width: 8),
                    Text(_i18n.get("unpin")),
                  ])),
          if (widget.message.type == MessageType.TEXT ||
              (widget.message.type == MessageType.FILE &&
                  widget.message.json!.toFile().caption.isNotEmpty))
            PopupMenuItem(
                onTap: onCopy,
                child: Row(children: [
                  const Icon(
                    Icons.content_copy,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(_i18n.get("copy")),
                ])),
          if (widget.message.type == MessageType.FILE)
            FutureBuilder(
                future: _fileRepo.getFileIfExist(
                    widget.message.json!.toFile().uuid,
                    widget.message.json!.toFile().name),
                builder: (c, fe) {
                  if (fe.hasData && fe.data != null) {
                    _fileIsExist.add(true);
                    model.File f = widget.message.json!.toFile();
                    return PopupMenuItem(
                        onTap: () {
                          if (f.type.contains("image")) {
                            onSaveTOGallery();
                          } else if (f.type.contains("audio") ||
                              f.type.contains("mp3")) {
                            // TODO ?????
                            onSaveToMusic();
                          } else {
                            onSaveTODownloads();
                          }
                        },
                        child: Row(children: [
                          Icon(f.type.contains("image")
                              ? Icons.image_outlined
                              : f.type.contains("audio") ||
                                      f.type.contains("mp3")
                                  ? Icons.queue_music_outlined
                                  : Icons.download_outlined),
                          const SizedBox(width: 8),
                          f.type.contains("image")
                              ? Text(_i18n.get("save_to_gallery"))
                              : f.type.contains("audio") ||
                                      f.type.contains("mp3")
                                  ? Text(_i18n.get("save_in_music"))
                                  : Text(_i18n.get("save_to_downloads")),
                        ]));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          if (widget.message.type == MessageType.FILE && !isDesktop())
            StreamBuilder<bool>(
                stream: _fileIsExist.stream,
                builder: (c, s) {
                  if (s.hasData && s.data!) {
                    _fileIsExist.add(true);
                    return PopupMenuItem(
                        onTap: onShare,
                        child: Row(children: [
                          const Icon(Icons.share),
                          const SizedBox(width: 8),
                          Text(_i18n.get("share")),
                        ]));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          if (widget.message.roomUid.isMuc())
            PopupMenuItem(
                onTap: onReportMessage,
                child: Row(children: [
                  const Icon(Icons.report_outlined),
                  const SizedBox(width: 8),
                  Text(_i18n.get("report")),
                ])),
          if (widget.message.id != null &&
              widget.message.type != MessageType.PERSISTENT_EVENT)
            PopupMenuItem(
                onTap: onForward,
                child: Row(children: [
                  const Icon(Icons.forward_outlined),
                  const SizedBox(width: 8),
                  Text(_i18n.get("forward")),
                ])),
          if (widget.message.id == null)
            FutureBuilder<PendingMessage?>(
                future: _messageRepo.getPendingMessage(widget.message.packetId),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.failed) {
                    return PopupMenuItem(
                        onTap: onResend,
                        child: Row(children: [
                          const Icon(Icons.refresh),
                          const SizedBox(width: 8),
                          Text(_i18n.get("resend")),
                        ]));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          if (_hasPermissionToDeleteMsg)
            widget.message.id != null
                ? deleteMenuWidget()
                : FutureBuilder<PendingMessage?>(
                    future:
                        _messageRepo.getPendingMessage(widget.message.packetId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.failed) {
                        return deleteMenuWidget();
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
          if (widget.message.id != null &&
              (widget.message.type == MessageType.TEXT ||
                  widget.message.type == MessageType.FILE) &&
              _autRepo.isCurrentUserSender(widget.message) &&
              checkMessageTime(widget.message))
            PopupMenuItem(
                onTap: onEditMessage,
                child: Row(children: [
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(_i18n.get("edit")),
                ])),
          if (isDesktop() && widget.message.type == MessageType.FILE)
            FutureBuilder<String?>(
                future: _fileRepo.getFileIfExist(
                    widget.message.json!.toFile().uuid,
                    widget.message.json!.toFile().name),
                builder: (c, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return PopupMenuItem(
                        onTap: () async =>
                            await onShowInFolder(snapshot, context),
                        child: Row(children: [
                          const Icon(Icons.folder_open_rounded),
                          const SizedBox(width: 8),
                          Text(_i18n.get("show_in_folder")),
                        ]));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
        ],
      ),
    );
  }

  Widget deleteMenuWidget() {
    return PopupMenuItem(
        onTap: () {
          widget.message.id != null
              ? onDeleteMessage()
              : onDeletePendingMessage();
        },
        child: Row(children: [
          const Icon(
            Icons.delete_outline_rounded,
            size: 21,
          ),
          const SizedBox(width: 7),
          Text(_i18n.get("delete")),
        ]));
  }

  bool checkMessageTime(Message message) {
    return DateTime.now().millisecondsSinceEpoch - message.time <=
        3 * 24 * 60 * 60 * 1000;
  }
}

void showDeleteMsgDialog(List<Message> messages, BuildContext context,
    Function? onDelete, int? roomLastMessageId) {
  var _i18n = GetIt.I.get<I18N>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  showDialog(
      context: context,
      builder: (c) => AlertDialog(
            title: Text(
              "${_i18n.get("delete")} ${messages.length > 1 ? messages.length : ""} ${_i18n.get("message")}",
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
            ),
            content: Text(messages.length > 1
                ? _i18n.get("sure_delete_messages")
                : _i18n.get("sure_delete_message")),
            actions: [
              GestureDetector(
                  child: Text(
                    _i18n.get("cancel"),
                    style: const TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    onDelete!();
                    Navigator.pop(c);
                  }),
              GestureDetector(
                child: Text(
                  _i18n.get("delete"),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _messageRepo.deleteMessage(messages, roomLastMessageId!);

                  onDelete!();
                  Navigator.pop(c);
                },
              ),
            ],
          ));
}
