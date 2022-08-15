import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/count_down_timer.dart';
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
    super.key,
    required this.message,
    required this.maxWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  });

  @override
  State<BotButtonsWidget> createState() => _BotButtonsWidgetState();
}

class _BotButtonsWidgetState extends State<BotButtonsWidget> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
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
      stream: _locked,
      builder: (context, lockData) {
        if (lockData.hasData && lockData.data != null) {
          final isLocked = lockData.data!;

          return Stack(
            children: [
              if (!buttons.lockAfter.isZero)
                CountDownTimer(
                  message: widget.message,
                  lockAfter: buttons.lockAfter.toInt(),
                  lock: (l) => _locked.add(l),
                ),
              Container(
                padding: EdgeInsets.only(
                  top: buttons.lockAfter.isZero ? 4 : 50,
                  left: 4,
                  right: 4,
                ),
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
                            primary: widget.colorScheme.primary,
                            onPrimary: widget.colorScheme.onPrimary,
                          ),
                          onPressed: !isLocked
                              ? () => _messageRepo.sendTextMessage(
                                    widget.message.from.asUid(),
                                    btn,
                                  )
                              : null,
                          child: Text(
                            btn,
                            textDirection: _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
