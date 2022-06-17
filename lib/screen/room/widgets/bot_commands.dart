import 'package:deliver/box/bot_info.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotCommands extends StatefulWidget {
  final Uid botUid;
  final String? query;
  final void Function(String) onCommandClick;
  final int botCommandSelectedIndex;

  const BotCommands({
    super.key,
    required this.botUid,
    required this.onCommandClick,
    this.query,
    required this.botCommandSelectedIndex,
  });

  @override
  BotCommandsState createState() => BotCommandsState();
}

class BotCommandsState extends State<BotCommands> {
  static final _botRepo = GetIt.I.get<BotRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<BotInfo?>(
      future: _botRepo.getBotInfo(widget.botUid),
      builder: (c, botInfo) {
        if (botInfo.hasData && botInfo.data != null) {
          final botCommands = <String, String>{};
          botInfo.data!.commands!.forEach((key, value) {
            if (key.contains(widget.query!)) {
              botCommands.putIfAbsent(key, () => value);
            }
          });
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: theme.backgroundColor,
            height: botCommands.keys.length * (24.0 + 16),
            child: Scrollbar(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: botCommands.length,
                itemBuilder: (c, index) {
                  var botCommandItemColor = Colors.transparent;
                  if (widget.botCommandSelectedIndex == index &&
                      widget.botCommandSelectedIndex != -1) {
                    botCommandItemColor = theme.focusColor;
                  }
                  return Container(
                    color: botCommandItemColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "/${botCommands.keys.toList()[index]}",
                                style: theme.textTheme.subtitle1,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    botCommands.values.toList()[index],
                                    style: theme.textTheme.bodyText2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.onCommandClick(
                              botCommands.keys.toList()[index],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
