import 'dart:convert';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotCommandsWidget extends StatefulWidget {
  final Uid botUid;
  final Function onCommandClick;

  BotCommandsWidget({this.botUid, this.onCommandClick});

  @override
  _BotCommandsWidgetState createState() => _BotCommandsWidgetState();
}

class _BotCommandsWidgetState extends State<BotCommandsWidget> {
  var _botRepo = GetIt.I.get<BotRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BotInfo>(
      future: _botRepo.getBotInfo(widget.botUid),
      builder: (c, botInfo) {
        if (botInfo.hasData && botInfo.data != null) {
          Map<String, dynamic> botCommands = jsonDecode(botInfo.data.commands.toString());
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child:   SizedBox(
              height: botCommands.keys.length*32.toDouble(),
                  child:  Scrollbar(
                      child:ListView.builder(
                      itemCount: botCommands.length,
                      itemBuilder: (c, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "/"+botCommands.keys.toList()[index],
                                  style:
                                  TextStyle(color: Colors.black,fontSize: 18),
                                ),
                                Text(
                                  botCommands.values.toList()[index],
                                  style:
                                      TextStyle(color: Theme.of(context).primaryColor,fontSize: 14),
                                ),

                              ],
                            ),
                            onTap: () {
                              widget.onCommandClick(
                                  botCommands.keys.toList()[index]);
                            },
                          ),
                        );
                      })),
                ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

}
