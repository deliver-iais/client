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
              child: Column(
                children: [
                  Text(
                    form.title,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: SizedBox(
                      height: formResult.values.length>4?400:20*formResult.values.length.toDouble(),
                        width: 200,
                        child: ListView.builder(
                            itemCount: form.fields.length,
                            itemBuilder: (c, index) {
                              return Row(
                                children: [
                                  Text(
                                    "${form.fields[index].label} : ",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black),
                                  ),
                                  Text(
                                    formResult.values[form.fields[index].id],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  )
                                ],
                              );
                            })),
                  ),
                  //   TimeAndSeenStatus(message, true, true)
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
