import 'package:collection/collection.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/link_preview.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TextUI extends StatelessWidget {
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final String? searchTerm;
  final void Function(String) onUsernameClick;
  final void Function(String) onBotCommandClick;
  final bool isBotMessage;
  final CustomColorScheme colorScheme;

  TextUI({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.colorScheme,
    required this.onBotCommandClick,
    required this.onUsernameClick,
    this.minWidth = 0,
    this.isSender = false,
    this.isSeen = false,
    this.searchTerm,
  }) : isBotMessage = message.roomUid.asUid().isBot();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final text = extractText(message);

    final blocks = onePathMultiDetection(
      [Block(text: text, features: {})],
      detectorsWithSearchTermDetector(),
    );

    final link = blocks
            .firstWhere(
              (b) => b.features.whereType<UrlFeature>().isNotEmpty,
              orElse: () => const Block(text: "", features: {}),
            )
            .features
            .whereType<UrlFeature>()
            .firstOrNull
            ?.url ??
        "";

    final spans = onePathTransform(
      blocks,
      inlineSpanTransformer(
        defaultColor: colorScheme.onPrimaryContainer,
        linkColor: theme.colorScheme.primary,
        onIdClick: onUsernameClick,
        onBotCommandClick: onBotCommandClick,
        onUrlClick: (text) => _urlHandlerService.onUrlTap(text, context),
      ),
    );

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
      padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        textDirection: isSender ? TextDirection.ltr : TextDirection.rtl,
        children: [
          RichText(
            text: TextSpan(children: spans, style: theme.textTheme.bodyText2),
            textDirection:
                text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
          ),
          LinkPreview(
            link: link,
            maxWidth: maxWidth,
            backgroundColor:
                Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            foregroundColor: colorScheme.primary,
          ),
          TimeAndSeenStatus(
            message,
            isSender: isSender,
            isSeen: isSeen,
            needsPositioned: false,
          )
        ],
      ),
    );
  }

  String extractText(Message msg) {
    if (msg.type == MessageType.TEXT) {
      return msg.json.toText().text.trim();
    } else if (msg.type == MessageType.FILE) {
      return msg.json.toFile().caption.trim();
    } else {
      return "";
    }
  }
}

String synthesizeToOriginalWord(String text) {
  return text
      .replaceAll("\\*", "*")
      .replaceAll("\\_", "_")
      .replaceAll("\\||", "||")
      .replaceAll("\\~", "~");
}

String synthesize(String text) {
  return text
      .replaceAll("*", "\\*")
      .replaceAll("_", "\\_")
      .replaceAll("||", "\\||")
      .replaceAll("~", "\\~");
}
