import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:flutter/material.dart';

class OperationOnMessageEntry extends PopupMenuEntry<OperationOnMessage> {
  final Message message;
  final bool hasPermissionInChannel;

  OperationOnMessageEntry(this.message, {this.hasPermissionInChannel = true});

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
  onDeletePendingMessage() {
    Navigator.pop<OperationOnMessage>(context, OperationOnMessage.DELETE_PENDING_MESSAGE);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);

    return Container(
      height:widget.hasPermissionInChannel? 150:100,
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
