import 'dart:async';
import 'dart:math';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BotCommands extends StatefulWidget {
  final Uid botUid;
  final String? query;
  final void Function(String) onCommandClick;
  final BehaviorSubject<int> botCommandSelectedIndex;

  const BotCommands({
    super.key,
    required this.botUid,
    required this.onCommandClick,
    this.query,
    required this.botCommandSelectedIndex,
  });

  @override
  State<BotCommands> createState() => _BotCommandsState();
}

class _BotCommandsState extends State<BotCommands> {
  static final _botRepo = GetIt.I.get<BotRepo>();
  final ItemScrollController controller = ItemScrollController();
  StreamSubscription? _streamSubscription;
  int _itemCount = 0;

  @override
  void initState() {
    _streamSubscription =
        widget.botCommandSelectedIndex.distinct().listen((index) {
      if (controller.isAttached) {
        controller.scrollTo(
          index: index % _itemCount,
          duration: const Duration(milliseconds: 100),
          alignment: getAlignment(index, _itemCount),
        );
      }
    });
    super.initState();
  }

  double getAlignment(int index, int count) {
    final i = index % count;
    if (i == 0) {
      return 0;
    } else if (i == count - 2) {
      return 0.5;
    } else if (i == count - 1) {
      return 0.75;
    } else {
      return 0.25;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

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
          _itemCount = botCommands.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: theme.colorScheme.background,
            height: min(botCommands.keys.length, 4) *
                ((theme.textTheme.titleMedium?.fontSize ?? 16) + 24),
            child: Scrollbar(
              child: ScrollablePositionedList.separated(
                padding: EdgeInsets.zero,
                itemCount: botCommands.length,
                itemScrollController: controller,
                itemBuilder: (c, index) {
                  return StreamBuilder<int>(
                    stream: widget.botCommandSelectedIndex.stream,
                    builder: (context, snapshot) {
                      final currentIndex = (snapshot.data ?? 0) % _itemCount;
                      var botCommandItemColor = Colors.transparent;
                      if (currentIndex == index &&
                          currentIndex != -1 &&
                          isDesktopDevice) {
                        botCommandItemColor = theme.focusColor;
                      }
                      return Container(
                        color: botCommandItemColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "/${botCommands.keys.toList()[index]}",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Opacity(
                                      opacity: 0.6,
                                      child: Text(
                                        botCommands.values.toList()[index],
                                        style: theme.textTheme.bodyMedium,
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
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  thickness: 1,
                  height: 1,
                ),
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
