import 'dart:math';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class BotButtonsWidget extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const BotButtonsWidget({
    Key? key,
    required this.message,
    required this.maxWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  }) : super(key: key);

  @override
  State<BotButtonsWidget> createState() => _BotButtonsWidgetState();
}

class _BotButtonsWidgetState extends State<BotButtonsWidget> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<bool> _locked = BehaviorSubject.seeded(false);

  @override
  void initState() {
    if (!widget.message.json.toButtons().lockAfter.isZero &&
        DateTime.now().millisecondsSinceEpoch - widget.message.time >
            widget.message.json.toButtons().lockAfter.toInt()) {
      _locked.add(true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final buttons = widget.message.json.toButtons();
    return StreamBuilder<bool>(
        initialData: _locked.value,
        stream: _locked.stream,
        builder: (context, lockData) {
          if (lockData.hasData && lockData.data != null) {
            return Stack(
              children: [
                if (!buttons.lockAfter.isZero)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, top: 10, bottom: 25, right: 70,),
                        child: CircularCountDownTimer( // tod o check time be big of message time
                          duration:  lockData.data!?0: min(buttons.lockAfter.toInt() ~/ 1000,(DateTime.now().millisecondsSinceEpoch-widget.message.time)/1000).floor() ,
                          controller: CountDownController(),
                          width: 30,
                          height: 30,
                          ringColor: Colors.red,
                          fillColor: Colors.blueAccent,
                          strokeCap: StrokeCap.round,
                          textStyle: Theme.of(context).textTheme.bodyText2,
                          textFormat: CountdownTextFormat.SS,
                          isReverse: true,
                          autoStart: !lockData.data!,
                          isReverseAnimation: true,
                          onComplete: () => _locked.add(true),
                        ),
                      ),
                      Text(
                        lockData.data!
                            ? _i18n.get("remaining_time")
                            : _i18n.get("out_of_time"),
                      )
                    ],
                  ),
                Container(
                  padding: EdgeInsets.only(
                      top: buttons.lockAfter.isZero ? 1 : 50,
                      left: 4,
                      right: 4,
                      bottom: 1,),
                  // width: maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final btn in buttons.buttons)
                        Container(
                          constraints: const BoxConstraints(minHeight: 20),
                          width: widget.maxWidth,
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: lockData.data!
                                  ? Colors.black26
                                  : widget.colorScheme.primary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: tertiaryBorder,
                              ),
                            ),
                            onPressed: () => !_locked.value
                                ? _messageRepo.sendTextMessage(
                                    widget.message.from.asUid(), btn,)
                                : null,
                            child: Text(
                              btn,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0, left: 6.0),
                        child: TimeAndSeenStatus(
                          widget.message,
                          isSender: widget.isSender,
                          isSeen: widget.isSeen,
                          needsPositioned: false,
                          backgroundColor: widget.colorScheme.primaryContainer,
                          foregroundColor:
                              widget.colorScheme.onPrimaryContainerLowlight(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },);
  }
}
