import 'package:we/box/bot_info.dart';
import 'package:we/repository/botRepo.dart';
import 'package:we/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotCommands extends StatefulWidget {
  final Uid botUid;
  final String query;
  final Function onCommandClick;

  BotCommands({this.botUid, this.onCommandClick, this.query});

  @override
  _BotCommandsState createState() => _BotCommandsState();
}

class _BotCommandsState extends State<BotCommands> {
  var _botRepo = GetIt.I.get<BotRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BotInfo>(
      future: _botRepo.getBotInfo(widget.botUid),
      builder: (c, botInfo) {
        if (botInfo.hasData && botInfo.data != null) {
          Map<String, String> botCommands = Map();
          botInfo.data.commands.forEach((key, value) {
            if (key.contains(widget.query))
              botCommands.putIfAbsent(key, () => value);
          });
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            color: ExtraTheme.of(context).boxBackground,
            height: botCommands.keys.length * (26.0 + 16),
            child: Scrollbar(
                child: ListView.separated(
              itemCount: botCommands.length,
              itemBuilder: (c, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "/" + botCommands.keys.toList()[index],
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Opacity(
                              opacity: 0.6,
                              child: Text(
                                botCommands.values.toList()[index],
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        widget.onCommandClick(botCommands.keys.toList()[index]);
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: ExtraTheme.of(context).boxOuterBackground),
            )),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
