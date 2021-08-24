import 'package:deliver_flutter/box/bot_info.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotCommandsWidget extends StatefulWidget {
  final Uid botUid;
  final String query;
  final Function onCommandClick;

  BotCommandsWidget({this.botUid, this.onCommandClick, this.query});

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
          Map<String, String> botCommands = Map();
          botInfo.data.commands.forEach((key, value) {
            if (key.contains(widget.query))
              botCommands.putIfAbsent(key, () => value);
          });
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: ExtraTheme.of(context).boxBackground,
            ),
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
              separatorBuilder: (BuildContext context, int index) => Divider(),
            )),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
