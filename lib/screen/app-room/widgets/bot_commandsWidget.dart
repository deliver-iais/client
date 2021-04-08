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
          Map<String, String> botCommands = json.decode(botInfo.data.commands);
          return Container(
            child: Expanded(
                child: ListView.builder(
                    itemCount: botCommands.length,
                    itemBuilder: (c, index) {
                      return GestureDetector(
                        child: Text(
                          botCommands.keys.toList()[index],
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        onTap: () {
                          widget.onCommandClick(
                              botCommands.values.toList()[index]);
                          Navigator.pop(context);
                        },
                      );
                    })),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  @override
  void initState() {
    _botRepo.featchBotInfo(widget.botUid);
  }
}
