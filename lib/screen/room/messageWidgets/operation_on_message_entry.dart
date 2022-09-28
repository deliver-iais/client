import 'package:clock/clock.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
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
    super.key,
    required this.hasPermissionInChannel,
    required this.hasPermissionInGroup,
    required this.isPinned,
  });

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
    final theme = Theme.of(context);

    return FutureBuilder<PendingMessage?>(
      future: _messageRepo.getPendingEditedMessage(
        widget.message.roomUid,
        widget.message.id,
      ),
      builder: (context, pendingEditedMessage) {
        final isPendingMessage =
            widget.message.id == null || pendingEditedMessage.data != null;
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
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.reply),
                      const SizedBox(width: 8),
                      Text(
                        _i18n.get("reply"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if ((widget.message.roomUid.asUid().category ==
                          Categories.GROUP &&
                      widget.hasPermissionInGroup) ||
                  (widget.message.roomUid.asUid().category ==
                          Categories.CHANNEL &&
                      widget.hasPermissionInChannel))
                if (widget.message.type != MessageType.PERSISTENT_EVENT)
                  if (!widget.isPinned)
                    PopupMenuItem(
                      value: OperationOnMessage.PIN_MESSAGE,
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.pin),
                          const SizedBox(width: 8),
                          Text(
                            _i18n.get("pin"),
                            style: theme.primaryTextTheme.bodyText2,
                          ),
                        ],
                      ),
                    )
                  else
                    PopupMenuItem(
                      value: OperationOnMessage.UN_PIN_MESSAGE,
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.delete),
                          const SizedBox(width: 8),
                          Text(
                            _i18n.get("unpin"),
                            style: theme.primaryTextTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
              if (widget.message.type == MessageType.TEXT ||
                  (widget.message.type == MessageType.FILE &&
                      widget.message.json.toFile().caption.isNotEmpty))
                PopupMenuItem(
                  value: OperationOnMessage.COPY,
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _i18n.get("copy"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if (!isPendingMessage &&
                  (widget.message.type == MessageType.TEXT ||
                      widget.message.type == MessageType.FILE))
                PopupMenuItem(
                  value: OperationOnMessage.SELECT,
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_alt_circle,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _i18n.get("select"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if (widget.message.type == MessageType.FILE && !isDesktop)
                FutureBuilder(
                  future: _fileRepo.getFileIfExist(
                    widget.message.json.toFile().uuid,
                    widget.message.json.toFile().name,
                  ),
                  builder: (c, fe) {
                    if (fe.hasData && fe.data != null) {
                      _fileIsExist.add(true);
                      final f = widget.message.json.toFile();
                      return PopupMenuItem(
                        value: f.type.contains("image")
                            ? OperationOnMessage.SAVE_TO_GALLERY
                            : f.type.contains("audio") || f.type.contains("mp3")
                                ? OperationOnMessage.SAVE_TO_MUSIC
                                : OperationOnMessage.SAVE_TO_DOWNLOADS,
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.down_arrow),
                            const SizedBox(width: 8),
                            if (f.type.contains("image"))
                              Text(
                                _i18n.get("save_to_gallery"),
                                style: theme.primaryTextTheme.bodyText2,
                              )
                            else if (f.type.contains("audio") ||
                                f.type.contains("mp3"))
                              Text(
                                _i18n.get("save_in_music"),
                                style: theme.primaryTextTheme.bodyText2,
                              )
                            else
                              Text(
                                _i18n.get("save_to_downloads"),
                                style: theme.primaryTextTheme.bodyText2,
                              ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              if (widget.message.type == MessageType.FILE && isAndroid)
                StreamBuilder<bool>(
                  stream: _fileIsExist,
                  builder: (c, s) {
                    if (s.hasData && s.data!) {
                      _fileIsExist.add(true);
                      return PopupMenuItem(
                        value: OperationOnMessage.SHARE,
                        child: Row(
                          children: [
                            const Icon(Icons.share),
                            const SizedBox(width: 8),
                            Text(
                              _i18n.get("share"),
                              style: theme.primaryTextTheme.bodyText2,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              if (widget.message.type == MessageType.TEXT && isAndroid)
                PopupMenuItem(
                  value: OperationOnMessage.SHARE,
                  child: Row(
                    children: [
                      const Icon(Icons.share),
                      const SizedBox(width: 8),
                      Text(
                        _i18n.get("share"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if (widget.message.roomUid.isMuc())
                PopupMenuItem(
                  value: OperationOnMessage.REPORT,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.burst),
                      const SizedBox(width: 8),
                      Text(
                        _i18n.get("report"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if (!isPendingMessage &&
                  widget.message.type != MessageType.PERSISTENT_EVENT)
                PopupMenuItem(
                  value: OperationOnMessage.FORWARD,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.arrowshape_turn_up_right),
                      const SizedBox(width: 8),
                      Text(
                        _i18n.get("forward"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if (widget.message.id == null)
                FutureBuilder<PendingMessage?>(
                  future:
                      _messageRepo.getPendingMessage(widget.message.packetId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.failed) {
                      return PopupMenuItem(
                        value: OperationOnMessage.RESEND,
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.refresh),
                            const SizedBox(width: 8),
                            Text(
                              _i18n.get("resend"),
                              style: theme.primaryTextTheme.bodyText2,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              if (_hasPermissionToDeleteMsg)
                widget.message.id != null
                    ? deleteMenuWidget(
                        context,
                        isPendingEditedMessage:
                            pendingEditedMessage.data != null,
                      )
                    : FutureBuilder<PendingMessage?>(
                        future: _messageRepo
                            .getPendingMessage(widget.message.packetId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              _isDeletablePendingMessage(snapshot.data!)) {
                            return deleteMenuWidget(
                              context,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
              if (!isPendingMessage &&
                  (widget.message.type == MessageType.TEXT ||
                      widget.message.type == MessageType.FILE) &&
                  _autRepo.isCurrentUserSender(widget.message) &&
                  checkMessageTime(widget.message))
                PopupMenuItem(
                  value: OperationOnMessage.EDIT,
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.paintbrush,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _i18n.get("edit"),
                        style: theme.primaryTextTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              if (isDesktop && widget.message.type == MessageType.FILE)
                FutureBuilder<String?>(
                  future: _fileRepo.getFileIfExist(
                    widget.message.json.toFile().uuid,
                    widget.message.json.toFile().name,
                  ),
                  builder: (c, snapshot) {
                    if (snapshot.hasData) {
                      return PopupMenuItem(
                        value: OperationOnMessage.SHOW_IN_FOLDER,
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.folder_open),
                            const SizedBox(width: 8),
                            Text(
                              _i18n.get("show_in_folder"),
                              style: theme.primaryTextTheme.bodyText2,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isDeletablePendingMessage(PendingMessage pendingMessage) =>
      pendingMessage.msg.type == MessageType.FILE
          ? pendingMessage.status != SendingStatus.UPLOAD_FILE_COMPELED
          : pendingMessage.failed;

  Widget deleteMenuWidget(
    BuildContext context, {
    bool isPendingEditedMessage = false,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem(
      value: widget.message.id != null
          ? isPendingEditedMessage
              ? OperationOnMessage.DELETE_PENDING_EDITED_MESSAGE
              : OperationOnMessage.DELETE
          : OperationOnMessage.DELETE_PENDING_MESSAGE,
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.delete,
          ),
          const SizedBox(width: 8),
          Text(
            isPendingEditedMessage
                ? _i18n.get("cancel_sending")
                : _i18n.get("delete"),
            style: theme.primaryTextTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}

bool checkMessageTime(Message message) {
  return clock.now().millisecondsSinceEpoch - message.time <=
      3 * 24 * 60 * 60 * 1000;
}

void showDeleteMsgDialog(
  List<Message> messages,
  BuildContext context,
  void Function() onDelete,
) {
  final theme = Theme.of(context);
  final i18n = GetIt.I.get<I18N>();
  final messageRepo = GetIt.I.get<MessageRepo>();
  showDialog(
    context: context,
    builder: (c) => Directionality(
      textDirection: i18n.defaultTextDirection,
      child: AlertDialog(
        title: Text(
          "${i18n.get("delete")} ${messages.length > 1 ? messages.length : ""}${i18n.get("message")}",
          style: theme.textTheme.bodyLarge,
        ),
        content: Text(
          messages.length > 1
              ? i18n.get("sure_delete_messages")
              : i18n.get("sure_delete_message"),
        ),
        actions: [
          TextButton(
            child: Text(i18n.get("cancel"), style: theme.textTheme.bodyText2),
            onPressed: () {
              onDelete();
              Navigator.pop(c);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(i18n.get("delete")),
            onPressed: () async {
              // ignore: use_build_context_synchronously
              Navigator.pop(c);
              await messageRepo.deleteMessage(messages);
              onDelete();
            },
          ),
        ],
      ),
    ),
  );
}
