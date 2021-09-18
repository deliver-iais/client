import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:we/box/bot_info.dart';
import 'package:we/repository/botRepo.dart';
import 'package:we/services/raw_keyboard_service.dart';
import 'package:we/theme/extra_theme.dart';

class BotCommands extends StatefulWidget {
  final Uid botUid;
  final String query;
  final Function onCommandClick;
  final int botCommandSelectedIndex;

  BotCommands(
      {this.botUid,
      this.onCommandClick,
      this.query,
      this.botCommandSelectedIndex});

  @override
  _BotCommandsState createState() => _BotCommandsState();
}

class _BotCommandsState extends State<BotCommands> {
  var _botRepo = GetIt.I.get<BotRepo>();
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();

  @override
  Widget build(BuildContext context) {
    widget.query=="-" ? _rawKeyboardService.isScrollInBotCommand=false : _rawKeyboardService.isScrollInBotCommand=true;
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
                Color _botCommandItemColor = Colors.transparent;
                if (widget.botCommandSelectedIndex == index &&
                    widget.botCommandSelectedIndex != -1)
                  _botCommandItemColor = Theme.of(context).focusColor;
                return Container(
                  color: _botCommandItemColor,
                  child: Padding(
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
                          widget
                              .onCommandClick(botCommands.keys.toList()[index]);
                        },
                      ),
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
