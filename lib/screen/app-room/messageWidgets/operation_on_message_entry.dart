import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/mediaType.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

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
  onPinMessage(){
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.PIN_MESSAGE);
  }
  onUnPinMessage(){
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.UN_PIN_MESSAGE);
  }



  onDeletePendingMessage() {
    Navigator.pop<OperationOnMessage>(
        context, OperationOnMessage.DELETE_PENDING_MESSAGE);
  }

  FileRepo fileRepo = GetIt.I.get<FileRepo>();

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
          if (widget.hasPermissionInGroup)
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
                future: fileRepo.getFileIfExist(
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

          // Expanded(
          //   child: FlatButton(
          //       onPressed: () {
          //         onForward();
          //       },
          //       child: Row(children: [
          //         Icon(
          //           Icons.forward,
          //           size: 20,
          //         ),
          //         SizedBox(width: 8),
          //         Text(appLocalization.getTraslateValue("Forward")),
          //       ])),
          // ),
          if (widget.message.sendingFailed != null &&
              widget.message.sendingFailed)
            Expanded(
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
            ),
          if (widget.message.sendingFailed != null &&
              widget.message.sendingFailed)
            Expanded(
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
            ),

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
