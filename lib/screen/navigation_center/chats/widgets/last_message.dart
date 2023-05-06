import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AsyncLastMessage extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool showSender;
  final bool expandContent;
  final Color? highlightColor;
  final bool useMultiLineText;

  AsyncLastMessage({
    super.key,
    required Message message,
    this.showSender = false,
    this.expandContent = true,
    this.highlightColor,
    this.useMultiLineText = false,
  }) : messageSRF =
            _messageExtractorServices.extractMessageSimpleRepresentative(
          _messageExtractorServices.extractProtocolBufferMessage(message),
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<MessageSimpleRepresentative>(
      future: messageSRF,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: theme.textTheme.bodyMedium!.fontSize! + 7);
        }
        return LastMessage(
          key: key,
          messageSR: snapshot.data!,
          showSender: showSender,
          expandContent: expandContent,
          highlightColor: highlightColor,
          useMultiLineText: useMultiLineText,
        );
      },
    );
  }
}

class LastMessage extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  final MessageSimpleRepresentative messageSR;
  final bool showSender;
  final bool useMultiLineText;
  final bool expandContent;
  final Color? highlightColor;

  const LastMessage({
    super.key,
    required this.messageSR,
    this.showSender = false,
    this.expandContent = true,
    this.highlightColor,
    this.useMultiLineText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: Flex(
        direction: useMultiLineText ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (messageSR.senderIsAUserOrBot && showSender)
            Text(
              "${messageSR.sender.trim()}${useMultiLineText ? "" : ": "}",
              style: theme.primaryTextTheme.bodySmall?.copyWith(
                color: highlightColor,
              ),
            ),
          _buildLastMessageTextUi(theme),
        ],
      ),
    );
  }

  Widget _buildLastMessageTextUi(ThemeData theme) {
    return Flexible(
      fit: FlexFit.tight,
      child: SizedBox(
        width: double.infinity,
        child: RichText(
          textDirection: _i18n.defaultTextDirection,
          maxLines: 1,
          text: TextSpan(
            children: [
              if (messageSR.typeDetails.isNotEmpty)
                TextSpan(
                  text: messageSR.typeDetails,
                  style: theme.primaryTextTheme.bodySmall,
                ),
              if (messageSR.typeDetails.isNotEmpty && messageSR.text.isNotEmpty)
                TextSpan(
                  text: ", ",
                  style: theme.primaryTextTheme.bodySmall,
                ),
              if (messageSR.text.isNotEmpty)
                TextSpan(
                  children: buildText(theme),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> buildText(
    ThemeData theme,
  ) {
    final paths = onePath(
      [
        Block(
          text: messageSR.text
              .split("\n")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .join(" "),
          features: {},
        )
      ],
      detectorsWithSearchTermDetector(),
      simpleInlineSpanTransformer(
        defaultColor: theme.colorScheme.primary,
        linkColor: theme.colorScheme.primary,
      ),
    );
    return paths;
  }
}
