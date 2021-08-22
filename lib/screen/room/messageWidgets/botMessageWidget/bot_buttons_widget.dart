import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BotButtonsWidget extends StatelessWidget {
  final Message message;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  BotButtonsWidget({this.message});

  @override
  Widget build(BuildContext context) {
    var buttons = message.json.toButtons();
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 40 * buttons.buttons.length.toDouble(),
          width: 250,
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ListView.separated(
                itemCount: buttons.buttons.length,
                itemBuilder: (c, index) {
                  return Container(
                    width: 300,
                    height: 35,
                    child: OutlinedButton(
                        onPressed: () {
                          _messageRepo.sendTextMessage(
                              message.from.asUid(), buttons.buttons[index]);
                        },
                        style: OutlinedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        child: Text(
                          buttons.buttons[index],
                          // style: Theme.of(context).primaryTextTheme.bodyText2,
                        )),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    SizedBox(height: 5)),
          ),
        ),
        TimeAndSeenStatus(message, false, false, needsBackground: false),
      ],
    ));
  }
}
