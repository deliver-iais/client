import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:deliver_flutter/shared/extensions/json_extension.dart';

import '../timeAndSeenStatus.dart';

class BotSentFormWidget extends StatelessWidget {
  final Message message;
  final bool isSeen;

  BotSentFormWidget({this.message, this.isSeen});

  final _messageDao = GetIt.I.get<MessageRepo>();

  @override
  Widget build(BuildContext context) {
    var formResult = message.json.toFormResult();

    return FutureBuilder<Message>(
        future: _messageDao.getMessage(message.to, message.replyToId),
        builder: (c, messageByForm) {
          if (messageByForm.hasData && messageByForm.data != null) {
            formModel.Form form = messageByForm.data.json.toForm();
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
                                        getText(form, index, formResult),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      )
                                    ],
                                  );
                                })),
                      ),
                    ],
                  ),
                  TimeAndSeenStatus(message, true, true, isSeen),
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }

  String getText(
      formModel.Form form, int index, formModel.FormResult formResult) {
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
