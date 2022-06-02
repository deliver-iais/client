import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/link_preview.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TextUI extends StatelessWidget {
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
  final void Function() onSpoilerClick;
  final bool spoilText;

  TextUI({
    Key? key,
    required this.message,
    required this.maxWidth,
    required this.colorScheme,
    required this.onBotCommandClick,
    required this.onUsernameClick,
    this.minWidth = 0,
    this.isSender = false,
    this.isSeen = false,
    this.searchTerm,
    required this.onSpoilerClick,
    required this.spoilText,
  })  : isBotMessage = message.roomUid.asUid().isBot(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final text = extractText(message);
    final blocks = extractBlocks(
      text,
      onUsernameClick: onUsernameClick,
      context: context,
      isBotMessage: isBotMessage,
      onBotCommandClick: onBotCommandClick,
      searchTerm: searchTerm,
      onSpoilerClick: onSpoilerClick,
      onPrimaryContainer: colorScheme.onPrimaryContainer,
    );
    final spans = blocks.map<InlineSpan>((b) {
      var tap = b.text;
      if (b.type == "inlineURL" || b.type == "inlineId") {
        tap = b.matchText;
      }
      if (b.type == "spoiler" && !spoilText) {
        return WidgetSpan(
          child: GestureDetector(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextLoader(
                Text(b.text),
                showJustTextLoader: true,
                fitAsText: true,
              ),
            ),
            onTap: () => b.onTap!(tap),
          ),
        );
      }
      return TextSpan(
        text: b.text,
        style: b.style,
        recognizer: (b.onTap != null)
            ? (TapGestureRecognizer()..onTap = () => b.onTap!(tap))
            : null,
      );
    }).toList();
    String link;
    try {
      link = blocks.firstWhere((b) => b.type == "url").text;
    } catch (e) {
      link = "";
    }

    final double linkPreviewMaxWidth = min(
      blocks
              .map((b) => b.text.length)
              .reduce((value, element) => value < element ? element : value) *
          6.85,
      maxWidth,
    );

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
      padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        textDirection: isSender ? TextDirection.ltr : TextDirection.rtl,
        children: [
          SelectableText.rich(
            TextSpan(children: spans, style: theme.textTheme.bodyText2),
            textDirection:
                text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
          ),
          LinkPreview(
            link: link,
            maxWidth: linkPreviewMaxWidth,
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

List<Block> extractBlocks(
  String text, {
  BuildContext? context,
  Color? onPrimaryContainer,
  String? searchTerm,
  Function(String)? onUsernameClick,
  Function(String)? onBotCommandClick,
  bool isBotMessage = false,
  Function()? onSpoilerClick,
  String Function(String)? spoilTransformer,
}) {
  var blocks = <Block>[
    Block(
      text: text,
      style: TextStyle(color: onPrimaryContainer),
    )
  ];
  final parsers = <Parser>[
    UnderlineTextParser(),
    BoldTextParser(),
    ItalicTextParser(),
    StrikethroughTextParser(),
    SpoilerTextParser(onSpoilerClick ?? () {}, transformer: spoilTransformer),
    InlineIdParser(onUsernameClick: onUsernameClick),
    EmojiParser(),
    if (searchTerm != null && searchTerm.isNotEmpty)
      SearchTermParser(searchTerm),
    InlineUrlTextParser(),
    UrlParser(),
    IdParser(onUsernameClick ?? (text) {}),
    if (isBotMessage) BotCommandParser(onBotCommandClick ?? (text) {}),
  ];

  for (final p in parsers) {
    blocks = p.parse(blocks, context);
  }

  return blocks;
}

Future<void> onUrlTap(String uri, BuildContext context) async {
  if (uri.contains("$APPLICATION_DOMAIN/$JOIN") ||
      uri.contains("$APPLICATION_DOMAIN/$SPDA") ||
      uri.contains("$APPLICATION_DOMAIN/$TEXT")) {
    await handleJoinUri(context, uri);
  } else {
    await launch(uri);
  }
}

abstract class Parser {
  List<Block> parse(List<Block> blocks, BuildContext? context);
}

class UrlParser implements Parser {
  final RegExp regex = RegExp(
    r"(https?:\/\/(www\.)?)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)",
  );

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "url",
        onTap: context == null ? (uri) {} : (uri) => onUrlTap((uri), context),
        style: context != null
            ? TextStyle(color: Theme.of(context).primaryColor)
            : null,
      );
}

class IdParser implements Parser {
  final void Function(String) onUsernameClick;
  final RegExp regex = RegExp(r"[@][a-zA-Z]([a-zA-Z0-9_]){4,19}");

  IdParser(this.onUsernameClick);

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "id",
        onTap: (id) => onUsernameClick(id),
        style: context != null
            ? TextStyle(color: Theme.of(context).primaryColor)
            : null,
      );
}

class BoldTextParser implements Parser {
  final RegExp regex = RegExp(r"(?<!\\)(\*.+?(?<!\\)\*)");

  static String transformer(String m) {
    return m.substring(m.indexOf("*") + 1, m.lastIndexOf("*"));
  }

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "bold",
        transformer: BoldTextParser.transformer,
        style: const TextStyle(fontWeight: FontWeight.w800),
      );
}

class ItalicTextParser implements Parser {
  final RegExp regex = RegExp(r"(?<!\\)(__.+?(?<!\\)_)");

  static String transformer(String m) =>
      m.substring(m.indexOf("_") + 1, m.lastIndexOf("_"));

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "italic",
        transformer: ItalicTextParser.transformer,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      );
}

class UnderlineTextParser implements Parser {
  final RegExp regex = RegExp(r"(?<!\\)(__.+?(?<!\\)__)");

  static String transformer(String m) =>
      m.substring(m.indexOf("__") + 2, m.lastIndexOf("__"));

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "underline",
        transformer: UnderlineTextParser.transformer,
        style: const TextStyle(
          decoration: TextDecoration.underline,
        ),
      );
}

class StrikethroughTextParser implements Parser {
  final RegExp regex = RegExp(r"(?<!\\)(~.+?(?<!\\)~)");

  static String transformer(String m) =>
      m.substring(m.indexOf("~") + 1, m.lastIndexOf("~"));

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "strikethrough",
        transformer: StrikethroughTextParser.transformer,
        style: const TextStyle(
          decoration: TextDecoration.lineThrough,
        ),
      );
}

class SpoilerTextParser implements Parser {
  final void Function() onSpoilerClick;
  final String Function(String)? transformer;
  final RegExp regex = RegExp(r"([\\])\|\|(.+)([^\\])\|\|", dotAll: true);

  static String transform(String m) =>
      m.substring(m.indexOf("||") + 2, m.lastIndexOf("||"));

  SpoilerTextParser(
    this.onSpoilerClick, {
    this.transformer,
  });

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "spoiler",
        transformer: transformer ?? SpoilerTextParser.transform,
        onTap: (text) {
          onSpoilerClick();
        },
      );
}

class InlineUrlTextParser implements Parser {
  final RegExp regex = RegExp(
    r"\[(((?!]).)+)\]\((https?:\/\/(www\.)?)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)\)",
    dotAll: true,
  );

  static String transformer(String m) {
    return m.substring(1, m.indexOf("]"));
  }

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "inlineURL",
        onTap: context == null
            ? (text) {}
            : (text) => onUrlTap(
                  (text.substring(text.indexOf("]") + 2, text.indexOf(")"))),
                  context,
                ),
        transformer: InlineUrlTextParser.transformer,
        style: TextStyle(
          color: context != null ? Theme.of(context).primaryColor : null,
        ),
      );
}

class InlineIdParser implements Parser {
  final void Function(String)? onUsernameClick;
  final RegExp regex =
      RegExp(r"\[((?!]).)+\]\(we:\/\/user\?id=[a-zA-Z]([a-zA-Z0-9_]){4,19}\)");

  InlineIdParser({this.onUsernameClick});

  static String transformer(String m) {
    return m.substring(1, m.indexOf("]"));
  }

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "inlineId",
        transformer: InlineIdParser.transformer,
        onTap: (text) {
          final id =
              text.substring(text.indexOf("?id=") + 4, text.lastIndexOf(")"));
          if (onUsernameClick != null) {
            // ignore: prefer_null_aware_method_calls
            onUsernameClick!("@" + id);
          }
        },
        style: context != null
            ? TextStyle(color: Theme.of(context).primaryColor)
            : null,
      );
}

class EmojiParser implements Parser {
  final double fontSize;
  final RegExp regex = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+',
  );

  EmojiParser({this.fontSize = 18});

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "emoji",
        style: GoogleFonts.notoColorEmojiCompat(fontSize: fontSize),
      );
}

class BotCommandParser implements Parser {
  final void Function(String) onBotCommandClick;
  final RegExp regex = RegExp(r"[/]([a-zA-Z0-9_-]){5,40}");

  BotCommandParser(this.onBotCommandClick);

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        regex,
        "bot",
        onTap: (id) => onBotCommandClick(id),
        style: context != null
            ? TextStyle(color: Theme.of(context).primaryColor)
            : null,
      );
}

class SearchTermParser implements Parser {
  final String searchTerm;

  SearchTermParser(this.searchTerm);

  @override
  List<Block> parse(List<Block> blocks, BuildContext? context) => parseBlocks(
        blocks,
        RegExp(searchTerm),
        "search",
        style: context != null
            ? TextStyle(color: Theme.of(context).primaryColor)
            : null,
      );
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

class Block {
  final String text;
  final bool locked;
  final String matchText;
  final void Function(String)? onTap;
  final TextStyle? style;
  final String? type;

  Block({
    this.matchText = "",
    required this.text,
    this.locked = false,
    this.onTap,
    this.style,
    this.type,
  });
}

List<Block> parseBlocks(
  List<Block> blocks,
  RegExp regex,
  String type, {
  void Function(String)? onTap,
  TextStyle? style,
  String Function(String) transformer = same,
}) =>
    flatten(
      blocks.map<Iterable<Block>>((b) {
        if (b.locked) {
          return [b];
        } else {
          return parseText(
            b.text,
            regex,
            onTap,
            style ?? const TextStyle(),
            type,
            transformer: transformer,
          );
        }
      }),
    ).toList();

List<Block> parseText(
  String text,
  RegExp regex,
  void Function(String)? onTap,
  TextStyle style,
  String type, {
  String Function(String) transformer = same,
}) {
  if (type == "inlineId") {
    text = synthesizeToOriginalWord(text);
  }
  var start = 0;

  final matches = regex.allMatches(text);

  final result = <Block>[];

  for (final match in matches) {
    result
      ..add(Block(text: text.substring(start, match.start)))
      ..add(
        Block(
          matchText: match[0]!,
          text: transformer(match[0]!),
          onTap: onTap,
          style: style,
          type: type,
          locked: true,
        ),
      );
    start = match.end;
  }

  result.add(Block(text: text.substring(start)));

  return result;
}

String same(String m) => m;

Iterable<T> flatten<T>(Iterable<Iterable<T>> items) sync* {
  for (final i in items) {
    yield* i;
  }
}
