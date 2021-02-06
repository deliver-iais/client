import 'dart:convert';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

import '../timeAndSeenStatus.dart';

class BotSendedFormWidget extends StatelessWidget {
  final Message message;

  BotSendedFormWidget({this.message});

  MessageDao _messageDao = GetIt.I.get<MessageDao>();
  proto.FormResult formResult;

  @override
  Widget build(BuildContext context) {
    formResult = message.json.toFormResult();

    return StreamBuilder<Message>(
        stream: _messageDao.getById(message.replyToId, message.to),
        builder: (c, messageByForm) {
          if (messageByForm.hasData && messageByForm.data != null) {
            proto.Form form = messageByForm.data.json.toForm();
            return Container(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Text(
                        form.title,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: SizedBox(
                            height: 20 * form.fields.length.toDouble(),
                            width: 250,
                            child: Scrollbar(
                                child: ListView.builder(
                                    itemCount: form.fields.length,
                                    itemBuilder: (c, index) {
                                      return Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${form.fields[index].label} : ",
                                            style: TextStyle(
                                                fontSize: 13, color: Colors.black),
                                          ),
                                          Text(
                                            getText(form, index),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.white),
                                          )
                                        ],
                                      );
                                    }))),
                      ),
                    ],
                  ),

                  TimeAndSeenStatus(message, true, true),
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }

  String getText(proto.Form form, int index) {
    var body = formResult.values[form.fields[index].id];
    String text = "";
    if (body == null) {
      return "";
    } else {
      int textLenght = body.length;
      if (textLenght > 25) {
        int d = (textLenght / 25).floor();
        int i = 0;
        while (i <= d) {
          if (i < d) {
            text = text + body.substring(i * 25, (((i + 1) * 25) - 1)) + "\n";
          } else {
            text = text + body.substring(i * 25, textLenght);
          }
          i++;
        }
        return text;
      } else
        return body;
    }
  }
}
