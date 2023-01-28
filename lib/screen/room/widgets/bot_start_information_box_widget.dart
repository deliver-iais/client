import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

class BotStartInformationBoxWidget extends StatelessWidget {
  final Uid roomUid;
  static final _botRepo = GetIt.I.get<BotRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _uxService = GetIt.I.get<UxService>();
  final backGroundColors = <Color>[
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .primary
          .get(80),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .tertiary
          .get(80),
    ),
  ];

  BotStartInformationBoxWidget({Key? key, required this.roomUid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<BotInfo?>(
      future: _botRepo.getBotInfo(roomUid),
      builder: (c, botInfo) {
        final showBox=botInfo.hasData &&
            botInfo.data != null &&
            botInfo.data!.description != null &&
            botInfo.data!.description!.isNotEmpty;
          final botCommands = botInfo.data?.commands;
          final botDescription = botInfo.data?.description;
          return  PageTransitionSwitcher(
              transitionBuilder: (
                  child,
                  animation,
                  secondaryAnimation,
                  ) {
                return FadeThroughTransition(
                  fillColor: Colors.transparent,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
            child: showBox ? Container(
              decoration: const BoxDecoration(
                boxShadow: DEFAULT_BOX_SHADOWS,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    elevation: 1.0,
                    type: MaterialType.card,
                    child: Container(
                      width: 300,
                      constraints: const BoxConstraints(maxHeight: 500),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.3),
                            backGroundColors[0].withOpacity(0.3),
                            backGroundColors[1].withOpacity(0.3),
                            theme.colorScheme.tertiary.withOpacity(0.3)
                          ],
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                botDescription!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textDirection: _i18n.getDirection(botDescription),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: botCommands!.length,
                                itemBuilder: (c, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "/${botCommands.keys.toList()[index]}",
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                botCommands.values
                                                    .toList()[index],
                                                textDirection: TextDirection.rtl,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          _messageRepo.sendTextMessage(
                                            roomUid,
                                            "/${botCommands.keys.toList()[index]}",
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ):const SizedBox.shrink(),
          );

      },
    );
  }
}
