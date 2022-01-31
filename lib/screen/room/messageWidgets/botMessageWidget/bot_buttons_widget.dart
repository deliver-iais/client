import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class BotButtonsWidget extends StatelessWidget {
  final Message message;
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final double maxWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  BotButtonsWidget(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.isSender,
      required this.colorScheme,
      required this.isSeen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buttons = message.json!.toButtons();
    return Container(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 1),
        width: maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final btn in buttons.buttons)
              Container(
                constraints: const BoxConstraints(minHeight: 40),
                width: maxWidth,
                margin: const EdgeInsets.only(bottom: 6),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(primary: colorScheme.primary),
                    onPressed: () {
                      _messageRepo.sendTextMessage(message.from.asUid(), btn);
                    },
                    child: Text(btn, textAlign: TextAlign.center)),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 6.0, left: 6.0),
              child: TimeAndSeenStatus(message, isSender, isSeen,
                  needsPadding: false,
                  needsPositioned: false,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainerVariant()),
            ),
          ],
        ));
  }
}
