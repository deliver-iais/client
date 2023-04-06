import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
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
  final void Function(String) onUsernameClick;
  final void Function(String) onBotCommandClick;

  const BotButtonsWidget({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
    required this.onUsernameClick,
    required this.onBotCommandClick,
  });

  @override
  State<BotButtonsWidget> createState() => _BotButtonsWidgetState();
}

class _BotButtonsWidgetState extends State<BotButtonsWidget> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<bool> _locked = BehaviorSubject.seeded(false);
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();

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
                padding: EdgeInsetsDirectional.only(
                  top: buttons.lockAfter.isZero ? 4 : 50,
                  end: 4,
                  start: 4,
                ),
                // width: maxWidth,
                child: Column(
                  children: [
                    if (buttons.text.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(minHeight: 20),
                        margin: const EdgeInsetsDirectional.symmetric(vertical: 8),
                        child: builtText(buttons.text),
                      ),
                    for (final btn in buttons.buttons)
                      Container(
                        constraints: const BoxConstraints(minHeight: 20),
                        width: widget.maxWidth,
                        margin: const EdgeInsetsDirectional.only(bottom: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.colorScheme.primary,
                            foregroundColor: widget.colorScheme.onPrimary,
                          ),
                          onPressed: !isLocked
                              ? () => _messageRepo.sendTextMessage(
                                    widget.message.from.asUid(),
                                    btn,
                                  )
                              : null,
                          child: Text(
                            btn,
                            textDirection: _i18n.getDirection(btn),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6.0),
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

  Widget builtText(String text) {
    final theme = Theme.of(context);
    final blocks = onePathMultiDetection(
      [Block(text: text, features: {})],
      detectorsWithSearchTermDetector(),
    );

    final spans = onePathTransform(
      blocks,
      inlineSpanTransformer(
        defaultColor: widget.colorScheme.onPrimaryContainer,
        linkColor: theme.colorScheme.primary,
        codeBackgroundColor: theme.colorScheme.secondaryContainer,
        codeForegroundColor: theme.colorScheme.onSecondaryContainer,
        onIdClick: widget.onUsernameClick,
        colorScheme: theme.colorScheme,
        onBotCommandClick: widget.onBotCommandClick,
        onUrlClick: (text) => _urlHandlerService.onUrlTap(text),
      ),
    );

    return RichText(
      text: TextSpan(children: spans, style: theme.textTheme.bodyMedium),
      textDirection: text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}
