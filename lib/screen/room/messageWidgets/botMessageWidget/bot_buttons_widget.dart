import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class BotButtonsWidget extends StatelessWidget {
  final Message message;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  BotButtonsWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buttons = message.json!.toButtons();
    return Container(
        padding: const EdgeInsets.only(top: 2, right: 2, left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final btn in buttons.buttons)
              Container(
                constraints: const BoxConstraints(minHeight: 35),
                width: 240,
                margin: const EdgeInsets.only(bottom: 5),
                child: OutlinedButton(
                    onPressed: () {
                      _messageRepo.sendTextMessage(message.from.asUid(), btn);
                    },
                    child: Text(btn, textAlign: TextAlign.center)),
              ),
            TimeAndSeenStatus(
              message,
              false,
              false,
              needsPadding: false,
              needsBackground: false,
              needsPositioned: false,
            ),
          ],
        ));
  }
}
