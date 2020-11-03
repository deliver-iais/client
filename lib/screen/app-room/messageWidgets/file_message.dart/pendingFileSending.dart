import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

import '../sending_file_circular_indicator.dart';

class PendingMessageFileSending extends StatelessWidget {
  PendingMessage pendingMessage;
  Message message;
  double maxWidth;

  PendingMessageFileSending(this.pendingMessage, this.message, this.maxWidth);

  var _messageDao = GetIt.I.get<MessageDao>();
  var _pendingMessageDao = GetIt.I.get<PendingMessageDao>();

  @override
  Widget build(BuildContext context) {
    filePb.File image = message.json.toFile();
    var width = image.width.toDouble();
    var height = image.height.toDouble();
    if (maxWidth < width) width = maxWidth;
    if (maxWidth * 1.2 < height) height = maxWidth;

    String path = (jsonDecode(pendingMessage.details))['path'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: const EdgeInsets.all(2),
          color: Theme.of(context).primaryColor,
          child: Column(children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  File(path),
                  width: 200,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                SendingFileCircularIndicator(
                  loadProgress:
                      pendingMessage.status == SendingStatus.PENDING ? 1 : 0.8,
                  isMedia: true,
                  cancelUpload: () {
                    _pendingMessageDao.deletePendingMessage(pendingMessage);
                    _messageDao.deleteMessage(message);
                  },
                ),
              ],
            ),
            message.json.toFile().caption.isNotEmpty
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: TextUi(
                      content: message.json.toFile().caption,
                      maxWidth: maxWidth,
                      lastCross: (c){},
                      isCaption: true,
                    ),
                  )
                : SizedBox.shrink()
          ]),
        ),
      ),
    );
  }
}
