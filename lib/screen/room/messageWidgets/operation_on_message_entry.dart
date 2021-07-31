import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as model;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

class OperationOnMessageEntry extends PopupMenuEntry<OperationOnMessage> {
  final Message message;
  final bool hasPermissionInChannel;
  final bool hasPermissionInGroup;
  final bool isPinned;

  OperationOnMessageEntry(this.message,
      {this.hasPermissionInChannel = true,
      this.hasPermissionInGroup = true,
      this.isPinned = false});

  @override
  OperationOnMessageEntryState createState() => OperationOnMessageEntryState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnMessage value) =>
      value == OperationOnMessage.REPLY;
}

class OperationOnMessageEntryState extends State<OperationOnMessageEntry> {
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  onReply() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.REPLY);
  }

  onCopy() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.COPY);
  }

  onForward() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.FORWARD);
  }

  onEdit() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.EDIT);
  }

  onDelete() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.DELETE);
  }

  onResend() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.RESEND);
  }

  onShare() {
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
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.SAVE_TO_DOWNLOADS);
  }

  onSaveToMusic() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.SAVE_TO_MUSIC);
  }

  onDeletePendingMessage() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.DELETE_PENDING_MESSAGE);
  }

  BehaviorSubject<bool> _fileIsExist = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);

    return Container(
      height: widget.hasPermissionInChannel ? 150 : 100,
      child: Column(
        children: [
          if (widget.hasPermissionInChannel && widget.message.id != null)
            Expanded(
              child: TextButton(
                  onPressed: () {
                    onReply();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.reply,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(i18n.get("Reply")),
                  ])),
            ),
          if ((widget.message.roomUid.asUid().category == Categories.GROUP &&
                  widget.hasPermissionInGroup) ||
              (widget.message.roomUid.asUid().category == Categories.CHANNEL &&
                  widget.hasPermissionInChannel))
            if (!widget.isPinned)
              Expanded(
                child: TextButton(
                    onPressed: () {
                      onPinMessage();
                    },
                    child: Row(children: [
                      Icon(
                        Icons.push_pin,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(i18n.get("pin")),
                    ])),
              )
            else
              Expanded(
                child: TextButton(
                    onPressed: () {
                      onUnPinMessage();
                    },
                    child: Row(children: [
                      Icon(
                        Icons.remove,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(i18n.get("unpin")),
                    ])),
              ),

          if (widget.message.type == MessageType.TEXT ||
              widget.message.type == MessageType.FILE)
            Expanded(
              child: TextButton(
                  onPressed: () {
                    onCopy();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.content_copy,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(i18n.get("copy")),
                  ])),
            ),
          if (widget.message.type == MessageType.FILE)
            FutureBuilder(
                future: _fileRepo.getFileIfExist(
                    widget.message.json.toFile().uuid,
                    widget.message.json.toFile().name),
                builder: (c, fe) {
                  if (fe.hasData && fe.data != null) {
                    _fileIsExist.add(true);
                    model.File f = widget.message.json.toFile();
                    return Expanded(
                      child: TextButton(
                          onPressed: () {
                            if (f.type.contains("image")) {
                              onSaveTOGallery();
                            } else if (f.type.contains("audio") ||
                                f.type.contains("mp3")) { // TODO ?????
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
                                ? Text(i18n.get("save_to_gallery"))
                                : f.type.contains("audio") ||
                                        f.type.contains("mp3")
                                    ? Text(i18n.get("save_in_music"))
                                    : Text(i18n.get("save_to_downloads")),
                          ])),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),

          if (widget.message.type == MessageType.FILE && !isDesktop())
            StreamBuilder<bool>(
                stream: _fileIsExist.stream,
                builder: (c, s) {
                  if (s.hasData && s.data) {
                    _fileIsExist.add(true);
                    return Expanded(
                      child: TextButton(
                          onPressed: () {
                            onShare();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.share,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(i18n.get("share")),
                          ])),
                    );
                  } else
                    return SizedBox.shrink();
                }),

          if (widget.message.id != null)
            Expanded(
              child: TextButton(
                  onPressed: () {
                    onForward();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.forward,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(i18n.get("forward")),
                  ])),
            ),
          if (widget.message.id == null)
            FutureBuilder<PendingMessage>(
                future: _messageRepo.getPendingMessage(widget.message.packetId),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data.failed != null &&
                      snapshot.data.failed) {
                    return Expanded(
                      child: TextButton(
                          onPressed: () {
                            onResend();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.refresh,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(i18n.get("resend")),
                          ])),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
          if (widget.message.id == null)
            FutureBuilder<PendingMessage>(
                future: _messageRepo.getPendingMessage(widget.message.packetId),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data.failed != null &&
                      snapshot.data.failed) {
                    return Expanded(
                      child: TextButton(
                          onPressed: () {
                            onDeletePendingMessage();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(i18n.get("delete")),
                          ])),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),

          // widget.message.type == MessageType.TEXT
          //     ? Expanded(
          //         child: FlatButton(
          //             onPressed: () {
          //               onEdit();
          //             },
          //             child: Row(children: [
          //               Icon(
          //                 Icons.edit,
          //                 size: 20,
          //               ),
          //               SizedBox(width: 8),
          //               Text(i18n.getTraslateValue("edit")),
          //             ])),
          //       )
          //     : Container(),
          // Expanded(
          //   child: FlatButton(
          //       onPressed: () {
          //         onDelete();
          //       },
          //       child: Row(children: [
          //         Icon(
          //           Icons.delete,
          //           size: 20,
          //         ),
          //         SizedBox(width: 8),
          //         Text(i18n.getTraslateValue("delete")),
          //       ])),
          // ),
        ],
      ),
    );
  }
}
