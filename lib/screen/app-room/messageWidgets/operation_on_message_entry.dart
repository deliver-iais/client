import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class OperationOnMessageEntry extends PopupMenuEntry<OperationOnMessage> {
  final Message message;
  final bool hasPermissionInChannel;
  final bool hasPermissionInGroup;
  final bool isPined;

  OperationOnMessageEntry(this.message,
      {this.hasPermissionInChannel = true,
      this.hasPermissionInGroup = true,
      this.isPined = false});

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

  onDeletePendingMessage() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.DELETE_PENDING_MESSAGE);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);

    return Container(
      height: widget.hasPermissionInChannel ? 150 : 100,
      child: Column(
        children: [
          if (widget.hasPermissionInChannel)
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    onReply();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.reply,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(appLocalization.getTraslateValue("Reply")),
                  ])),
            ),
          if ((widget.message.roomUid.asUid().category == Categories.GROUP &&
                  widget.hasPermissionInGroup) ||
              (widget.message.roomUid.asUid().category == Categories.CHANNEL &&
                  widget.hasPermissionInChannel))
            if (!widget.isPined)
              Expanded(
                child: FlatButton(
                    onPressed: () {
                      onPinMessage();
                    },
                    child: Row(children: [
                      Icon(
                        Icons.push_pin,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(appLocalization.getTraslateValue("pin")),
                    ])),
              )
            else
              Expanded(
                child: FlatButton(
                    onPressed: () {
                      onUnPinMessage();
                    },
                    child: Row(children: [
                      Icon(
                        Icons.remove,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(appLocalization.getTraslateValue("Unpin")),
                    ])),
              ),

          if (widget.message.type == MessageType.TEXT ||
              widget.message.type == MessageType.FILE)
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    onCopy();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.content_copy,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(appLocalization.getTraslateValue("Copy")),
                  ])),
            ),
          if (widget.message.type == MessageType.FILE && !isDesktop())
            FutureBuilder<File>(
                future: _fileRepo.getFileIfExist(
                    widget.message.json.toFile().uuid,
                    widget.message.json.toFile().name),
                builder: (c, s) {
                  if (s.hasData && s.data != null)
                    return Expanded(
                      child: FlatButton(
                          onPressed: () {
                            onShare();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.share,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(appLocalization.getTraslateValue("share")),
                          ])),
                    );
                  else
                    return SizedBox.shrink();
                }),

          Expanded(
            child: FlatButton(
                onPressed: () {
                  onForward();
                },
                child: Row(children: [
                  Icon(
                    Icons.forward,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(appLocalization.getTraslateValue("Forward")),
                ])),
          ),
          if (widget.message.id == null)
            FutureBuilder<PendingMessage>(
                future: _messageRepo.getPendingMessage(
                    widget.message.roomUid, widget.message.packetId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Expanded(
                      child: FlatButton(
                          onPressed: () {
                            onResend();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.refresh,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(appLocalization.getTraslateValue("Resend")),
                          ])),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
          if (widget.message.id == null)
            FutureBuilder<PendingMessage>(
                future: _messageRepo.getPendingMessage(
                    widget.message.roomUid, widget.message.packetId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Expanded(
                      child: FlatButton(
                          onPressed: () {
                            onDeletePendingMessage();
                          },
                          child: Row(children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(appLocalization.getTraslateValue("delete")),
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
          //               Text(appLocalization.getTraslateValue("Edit")),
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
          //         Text(appLocalization.getTraslateValue("Delete")),
          //       ])),
          // ),
        ],
      ),
    );
  }
}
