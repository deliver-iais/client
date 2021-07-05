import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BotButtonsWidget extends StatelessWidget {
  final Message message;

  BotButtonsWidget({this.message});

  MessageRepo _messageRepo = GetIt.I.get<MessageRepo>();

  Buttons buttons;

  @override
  Widget build(BuildContext context) {
    buttons = message.json.toButtons();
    return Container(
        child: Stack(
      children: [
        SizedBox(
          height: 60 * buttons.buttons.length.toDouble(),
          width: 200,
          child:  ListView.builder(
              itemCount: buttons.buttons.length,
              itemBuilder: (c, index) {
                return Center(
                  child: Column(
                    children: [
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: Colors.blue)),
                          color: Colors.blueAccent,
                          onPressed: () {
                            _messageRepo.sendTextMessage(
                                message.from.asUid(), buttons.buttons[index]);
                          },
                          child: Text(buttons.buttons[index])),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                );
              }),
        ),
        TimeAndSeenStatus(message, false, true,false),
      ],
    ));
  }
}
