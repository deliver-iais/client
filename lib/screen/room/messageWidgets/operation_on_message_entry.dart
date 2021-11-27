import 'dart:io';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as model;
import 'package:ext_storage/ext_storage.dart';
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
  final Function? onDelete;
  int? roomLastMessageId = 1;

  OperationOnMessageEntry(
    this.message, {
    this.hasPermissionInChannel = true,
    this.hasPermissionInGroup = true,
    this.isPinned = false,
    this.onDelete,
    this.roomLastMessageId,
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
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _autRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _logger = GetIt.I.get<Logger>();

  onReply() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.REPLY);
  }

  onCopy() {
    if (widget.message.type == MessageType.TEXT)
      Clipboard.setData(
          ClipboardData(text: widget.message.json!.toText().text));
    else
      Clipboard.setData(
          ClipboardData(text: widget.message.json!.toFile().caption));
    ToastDisplay.showToast(
        toastText: _i18n.get("copied"), tostContext: context);
    Navigator.pop(context);
  }

  onForward() {
    _routingServices
        .openSelectForwardMessage(context, forwardedMessages: [widget.message]);
    Navigator.pop(context);
  }

  onEditMessage() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.EDIT);
  }

  onResend() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.RESEND);
  }

  onShare() async {
    try {
      var result = await _fileRepo.getFileIfExist(
          widget.message.json!.toFile().uuid,
          widget.message.json!.toFile().name);
      if (result!.path.isNotEmpty)
        Share.shareFiles(['${result.path}'],
            text: widget.message.json!.toFile().caption.isNotEmpty
                ? widget.message.json!.toFile().caption
                : 'Deliver');
    } catch (e) {
      _logger.e(e);
    }
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.SHARE);
  }

  onPinMessage() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.PIN_MESSAGE);
  }

  onUnPinMessage() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.UN_PIN_MESSAGE);
  }

  onSaveTOGallery() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.SAVE_TO_GALLERY);
  }

  onSaveTODownloads() {
    var file = widget.message.json!.toFile();
    _fileRepo.saveFileInDownloadDir(
        file.uuid, file.name, ExtStorage.DIRECTORY_DOWNLOADS);
    Navigator.pop(context);
  }

  onSaveToMusic() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.SAVE_TO_MUSIC);
  }

  onDeleteMessage() {
    Navigator.pop(context);
    showDeleteMsgDialog([widget.message], context, widget.onDelete, widget.roomLastMessageId);

  }

  onDeletePendingMessage() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.DELETE_PENDING_MESSAGE);
  }

  onReportMessage() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.REPORT);
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
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.SHOW_IN_FOLDER);
  }

  BehaviorSubject<bool> _fileIsExist = BehaviorSubject.seeded(false);
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
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.hasPermissionInChannel && widget.message.id != null)
              TextButton(
                  onPressed: () {
                    onReply();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.reply,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(_i18n.get("Reply")),
                  ])),
            if ((widget.message.roomUid.asUid().category == Categories.GROUP &&
                    widget.hasPermissionInGroup) ||
                (widget.message.roomUid.asUid().category ==
                        Categories.CHANNEL &&
                    widget.hasPermissionInChannel))
              if (!widget.isPinned)
                TextButton(
                    onPressed: () {
                      onPinMessage();
                    },
                    child: Row(children: [
                      Icon(
                        Icons.push_pin,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(_i18n.get("pin")),
                    ]))
              else
                TextButton(
                    onPressed: () {
                      onUnPinMessage();
                    },
                    child: Row(children: [
                      Icon(
                        Icons.remove,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(_i18n.get("unpin")),
                    ])),
            if (widget.message.type == MessageType.TEXT ||
                (widget.message.type == MessageType.FILE &&
                    widget.message.json!.toFile().caption.isNotEmpty))
              TextButton(
                  onPressed: () {
                    onCopy();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.content_copy,
                      size: 20,
                    ),
                    SizedBox(width: 8),
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
                      return TextButton(
                          onPressed: () {
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
                            Icon(
                              f.type.contains("image")
                                  ? Icons.image
                                  : f.type.contains("audio") ||
                                          f.type.contains("mp3")
                                      ? Icons.queue_music_rounded
                                      : Icons.download_rounded,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            f.type.contains("image")
                                ? Text(_i18n.get("save_to_gallery"))
                                : f.type.contains("audio") ||
                                        f.type.contains("mp3")
                                    ? Text(_i18n.get("save_in_music"))
                                    : Text(_i18n.get("save_to_downloads")),
                          ]));
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
            if (widget.message.type == MessageType.FILE && !isDesktop())
              StreamBuilder<bool>(
                  stream: _fileIsExist.stream,
                  builder: (c, s) {
                    if (s.hasData && s.data!) {
                      _fileIsExist.add(true);
                      return TextButton(
                          onPressed: () {
                            onShare();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.share,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(_i18n.get("share")),
                          ]));
                    } else
                      return SizedBox.shrink();
                  }),
            if (widget.message.roomUid.isMuc())
              TextButton(
                  onPressed: () {
                    onReportMessage();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.report,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(_i18n.get("report")),
                  ])),
            if (widget.message.id != null &&
                widget.message.type != MessageType.PERSISTENT_EVENT)
              TextButton(
                  onPressed: () {
                    onForward();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.forward,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(_i18n.get("forward")),
                  ])),
            if (widget.message.id == null)
              FutureBuilder<PendingMessage?>(
                  future:
                      _messageRepo.getPendingMessage(widget.message.packetId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.failed) {
                      return TextButton(
                          onPressed: () {
                            onResend();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.refresh,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(_i18n.get("resend")),
                          ]));
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
            if (_hasPermissionToDeleteMsg)
              widget.message.id != null
                  ? deleteMenuWidget()
                  : FutureBuilder<PendingMessage?>(
                      future: _messageRepo
                          .getPendingMessage(widget.message.packetId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.failed) {
                          return deleteMenuWidget();
                        } else {
                          return SizedBox.shrink();
                        }
                      }),
            if (widget.message.id != null &&
                (widget.message.type == MessageType.TEXT ||
                    widget.message.type == MessageType.FILE) &&
                _autRepo.isCurrentUserSender(widget.message) &&
                checkMessageTime(widget.message))
              TextButton(
                  onPressed: () {
                    onEditMessage();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.edit,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(_i18n.get("edit")),
                  ])),
            if (isDesktop() && widget.message.type == MessageType.FILE)
              FutureBuilder<File?>(
                  future: _fileRepo.getFileIfExist(
                      widget.message.json!.toFile().uuid,
                      widget.message.json!.toFile().name),
                  builder: (c, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return TextButton(
                          onPressed: () async {
                            await onShowInFolder(snapshot, context);
                          },
                          child: Row(children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(_i18n.get("show_in_folder")),
                          ]));
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
          ],
        ),
      ),
    );
  }

  TextButton deleteMenuWidget() {
    return TextButton(
        onPressed: () {
          widget.message.id != null
              ? onDeleteMessage()
              : onDeletePendingMessage();
        },
        child: Row(children: [
          Icon(
            Icons.delete,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(_i18n.get("delete")),
        ]));
  }

  bool checkMessageTime(Message message) {
    return DateTime.now().millisecondsSinceEpoch - message.time <=
        3 * 24 * 60 * 60 * 1000;
  }
}

void showDeleteMsgDialog(List<Message> messages, BuildContext context,
    Function ? onDelete, int? roomLastMessageId) {
  var _i18n = GetIt.I.get<I18N>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
 showDialog(
      context: context,
      builder: (c) => AlertDialog(
            title: Text(
              "${_i18n.get("delete")} ${messages.length > 1 ? messages.length : ""} ${_i18n.get("message")}",
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
            ),
            content: Text(messages.length > 1
                ? _i18n.get("sure_delete_messages")
                : _i18n.get("sure_delete_message")),
            actions: [
              GestureDetector(
                  child: Text(
                    _i18n.get("cancel"),
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    onDelete!();
                    Navigator.pop(c);
                  }),
              GestureDetector(
                child: Text(
                  _i18n.get("delete"),
                  style: TextStyle(color: Colors.red),
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
