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
import 'package:rxdart/rxdart.dart';

class TextUI extends StatefulWidget {
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

  final List<Block> blocks;
  final String text;

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
  })  : isBotMessage = message.roomUid.asUid().isBot(),
        text = _extractText(message),
        blocks = onePathMultiDetection(
          [Block(text: _extractText(message), features: {})],
          detectorsWithSearchTermDetector(),
        );

  static String _extractText(Message msg) {
    if (msg.type == MessageType.TEXT) {
      return msg.json.toText().text.trim();
    } else if (msg.type == MessageType.FILE) {
      return msg.json.toFile().caption.trim();
    } else {
      return "";
    }
  }

  @override
  State<TextUI> createState() => _TextUIState();
}

class _TextUIState extends State<TextUI> {
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _textBoxKey = GlobalKey();

  final _textBoxWidth = BehaviorSubject.seeded(0.0);
  String _link = "";

  @override
  void initState() {
    _link = widget.blocks
            .firstWhere(
              (b) => b.features.whereType<UrlFeature>().isNotEmpty,
              orElse: () => const Block(text: "", features: {}),
            )
            .features
            .whereType<UrlFeature>()
            .firstOrNull
            ?.url ??
        "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textBoxWidth.add(_textBoxKey.currentContext?.size?.width ?? 0);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final spans = onePathTransform(
      widget.blocks,
      inlineSpanTransformer(
        defaultColor: widget.colorScheme.onPrimaryContainer,
        linkColor: theme.colorScheme.primary,
        onIdClick: widget.onUsernameClick,
        onBotCommandClick: widget.onBotCommandClick,
        onUrlClick: (text) => _urlHandlerService.onUrlTap(text, context),
      ),
    );

    return Container(
      constraints:
          BoxConstraints(maxWidth: widget.maxWidth, minWidth: widget.minWidth),
      padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: widget.text.isPersian()
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              key: _textBoxKey,
              child: RichText(
                text:
                    TextSpan(children: spans, style: theme.textTheme.bodyText2),
                textDirection: widget.text.isPersian()
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
            ),
            StreamBuilder<double>(
              stream: _textBoxWidth,
              builder: (context, snapshot) {
                return LinkPreview(
                  link: _link,
                  maxWidth: snapshot.data ?? 0,
                  backgroundColor:
                      Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  foregroundColor: widget.colorScheme.primary,
                );
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TimeAndSeenStatus(
                widget.message,
                isSender: widget.isSender,
                isSeen: widget.isSeen,
                needsPositioned: false,
              ),
            )
          ],
        ),
      ),
    );
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
