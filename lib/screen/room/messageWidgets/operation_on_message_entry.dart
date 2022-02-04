import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as model;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class OperationOnMessageEntry extends PopupMenuEntry<OperationOnMessage> {
  final Message message;
  final bool hasPermissionInChannel;
  final bool hasPermissionInGroup;
  final bool isPinned;

  const OperationOnMessageEntry(
    this.message, {
    Key? key,
    required this.hasPermissionInChannel,
    required this.hasPermissionInGroup,
    required this.isPinned,
  }) : super(key: key);

  @override
  OperationOnMessageEntryState createState() => OperationOnMessageEntryState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnMessage? value) =>
      value == OperationOnMessage.REPLY;
}

class OperationOnMessageEntryState extends State<OperationOnMessageEntry> {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _autRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

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
              value: OperationOnMessage.REPLY,
              child: Row(children: [
                const Icon(CupertinoIcons.reply),
                const SizedBox(width: 8),
                Text(_i18n.get("Reply")),
              ]),
            ),
          if ((widget.message.roomUid.asUid().category == Categories.GROUP &&
                  widget.hasPermissionInGroup) ||
              (widget.message.roomUid.asUid().category == Categories.CHANNEL &&
                  widget.hasPermissionInChannel))
            if (widget.message.type != MessageType.PERSISTENT_EVENT)
              if (!widget.isPinned)
                PopupMenuItem(
                    value: OperationOnMessage.PIN_MESSAGE,
                    child: Row(children: [
                      const Icon(CupertinoIcons.pin),
                      const SizedBox(width: 8),
                      Text(_i18n.get("pin")),
                    ]))
              else
                PopupMenuItem(
                    value: OperationOnMessage.UN_PIN_MESSAGE,
                    child: Row(children: [
                      const Icon(CupertinoIcons.delete),
                      const SizedBox(width: 8),
                      Text(_i18n.get("unpin")),
                    ])),
          if (widget.message.type == MessageType.TEXT ||
              (widget.message.type == MessageType.FILE &&
                  widget.message.json!.toFile().caption.isNotEmpty))
            PopupMenuItem(
                value: OperationOnMessage.COPY,
                child: Row(children: [
                  const Icon(
                    CupertinoIcons.doc_on_clipboard,
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
                        value: f.type.contains("image")
                            ? OperationOnMessage.SAVE_TO_GALLERY
                            : f.type.contains("audio") || f.type.contains("mp3")
                                ? OperationOnMessage.SAVE_TO_MUSIC
                                : OperationOnMessage.SAVE_TO_DOWNLOADS,
                        child: Row(children: [
                          const Icon(CupertinoIcons.down_arrow),
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
                        value: OperationOnMessage.SHARE,
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
                value: OperationOnMessage.REPORT,
                child: Row(children: [
                  const Icon(CupertinoIcons.burst),
                  const SizedBox(width: 8),
                  Text(_i18n.get("report")),
                ])),
          if (widget.message.id != null &&
              widget.message.type != MessageType.PERSISTENT_EVENT)
            PopupMenuItem(
                value: OperationOnMessage.FORWARD,
                child: Row(children: [
                  const Icon(CupertinoIcons.arrowshape_turn_up_right),
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
                        value: OperationOnMessage.RESEND,
                        child: Row(children: [
                          const Icon(CupertinoIcons.refresh),
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
                value: OperationOnMessage.EDIT,
                child: Row(children: [
                  const Icon(
                    CupertinoIcons.bandage,
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
                  if (snapshot.hasData) {
                    return PopupMenuItem(
                        value: OperationOnMessage.SHOW_IN_FOLDER,
                        child: Row(children: [
                          const Icon(CupertinoIcons.folder_open),
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
        value: widget.message.id != null
            ? OperationOnMessage.DELETE
            : OperationOnMessage.DELETE_PENDING_MESSAGE,
        child: Row(children: [
          const Icon(
            CupertinoIcons.delete,
          ),
          const SizedBox(width: 8),
          Text(_i18n.get("delete")),
        ]));
  }

  bool checkMessageTime(Message message) {
    return DateTime.now().millisecondsSinceEpoch - message.time <=
        3 * 24 * 60 * 60 * 1000;
  }
}

void showDeleteMsgDialog(
    List<Message> messages, BuildContext context, Function? onDelete) {
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
                  _messageRepo.deleteMessage(messages);

                  onDelete!();
                  Navigator.pop(c);
                },
              ),
            ],
            actionsPadding: const EdgeInsets.only(right: 12, bottom: 5),
          ));
}
