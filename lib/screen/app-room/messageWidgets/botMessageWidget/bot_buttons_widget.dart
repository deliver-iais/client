import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BotButtonsWidget extends StatelessWidget {
  final Message message;

  BotButtonsWidget({this.message});

  MessageRepo _messageRepo = GetIt.I.get<MessageRepo>();

  proto.Buttons buttons;

  @override
  Widget build(BuildContext context) {
    buttons = message.json.toButtons();
    return Container(
      child:Column(
        children: [
          SizedBox(
            height: 50*buttons.buttons.length.toDouble() ,
            width: 150,
            child: ListView.builder(
                itemCount: buttons.buttons.length,
                itemBuilder: (c, index) {
                  return Center(
                    child: Column(
                      children: [
                        FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.blue)),
                            onPressed: () {
                              _messageRepo.sendTextMessage(
                                  message.from.getUid(), buttons.buttons[index]);
                            },
                            child: Text(buttons.buttons[index])),
                        SizedBox(height: 5,)
                      ],
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100),
            child:  TimeAndSeenStatus(message, false, true),
            ),



        ],
      )
    );
  }
}
