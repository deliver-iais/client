import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/messageWidgets/link_preview.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
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
    final blocks = extractBlocks(text, context);
    final spans = blocks.map<TextSpan>((b) {
      var tap = b.text;
      if (b.type == "inlineURL" || b.type == "inlineId") {
        tap = text;
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
          RichText(
            text: TextSpan(children: spans, style: theme.textTheme.bodyText2),
            textDirection:
                text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
          ),
          LinkPreview(
            link: link,
            maxWidth: linkPreviewMaxWidth,
            backgroundColor: colorScheme.onPrimary,
            foregroundColor: colorScheme.primary,
          ),
          TimeAndSeenStatus(
            message,
            isSender: isSender,
            isSeen: isSeen,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainerLowlight(),
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

  List<Block> extractBlocks(String text, BuildContext context) {
    var blocks = <Block>[Block(text: text)];
    final parsers = <Parser>[
      EmojiParser(),
      if (searchTerm != null && searchTerm!.isNotEmpty)
        SearchTermParser(searchTerm!),
      InlineUrlTextParser(),
      UrlParser(),
      IdParser(onUsernameClick),
      if (isBotMessage) BotCommandParser(onBotCommandClick),
      UnderlineTextParser(),
      BoldTextParser(),
      ItalicTextParser(),
      StrikethroughTextParser(),
      SpoilerTextParser(onSpoilerClick, spoil: spoilText),
      InlineIdParser(onUsernameClick: onUsernameClick),
      TildeTextParser(),
      UnderScoreTextParser(),
      StarTextParser(),
    ];

    for (final p in parsers) {
      blocks = p.parse(blocks, context);
    }

    return blocks;
  }
}

abstract class Parser {
  List<Block> parse(List<Block> blocks, BuildContext context);
}

class UrlParser implements Parser {
  final RegExp regex = RegExp(
    r"(https?:\/\/(www\.)?)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)",
  );

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "url",
        onTap: (uri) async {
          if (uri.contains("$APPLICATION_DOMAIN/$JOIN") ||
              uri.contains("$APPLICATION_DOMAIN/$SPDA") ||
              uri.contains("$APPLICATION_DOMAIN/$TEXT")) {
            await handleJoinUri(context, uri);
          } else {
            await launch(uri);
          }
        },
        style: TextStyle(color: Theme.of(context).primaryColor),
      );
}

class IdParser implements Parser {
  final void Function(String) onUsernameClick;
  final RegExp regex = RegExp(r"[@][a-zA-Z]([a-zA-Z0-9_]){4,19}");

  IdParser(this.onUsernameClick);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "id",
        onTap: (id) => onUsernameClick(id),
        style: TextStyle(color: Theme.of(context).primaryColor),
      );
}

class BoldTextParser implements Parser {
  final RegExp regex = RegExp(r"(\*.+)([^\\])(\*)", dotAll: true);

  static String transformer(String m) => m.replaceAll("*", "");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "bold",
        transformer: BoldTextParser.transformer,
        style: const TextStyle(fontWeight: FontWeight.w800),
      );
}

class StarTextParser implements Parser {
  final RegExp regex = RegExp(r"(\\*.+)", dotAll: true);

  static String transformer(String m) => m.replaceAll("\\*", "*");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "star",
        transformer: StarTextParser.transformer,
        style: const TextStyle(),
      );
}

class UnderScoreTextParser implements Parser {
  final RegExp regex = RegExp(r"(\\_.+)", dotAll: true);

  static String transformer(String m) => m.replaceAll("\\_", "_");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "underScore",
        transformer: UnderScoreTextParser.transformer,
        style: const TextStyle(),
      );
}

class TildeTextParser implements Parser {
  final RegExp regex = RegExp(r"(\\~.+)", dotAll: true);

  static String transformer(String m) => m.replaceAll("\\~", "~");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "tilde",
        transformer: TildeTextParser.transformer,
        style: const TextStyle(),
      );
}

class ItalicTextParser implements Parser {
  final RegExp regex = RegExp(r"_(.+)([^\\])_", dotAll: true);

  static String transformer(String m) => m.replaceAll("_", "");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
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
  final RegExp regex = RegExp(r"__(.+)([^\\])__", dotAll: true);

  static String transformer(String m) => m.replaceAll("__", "");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
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
  final RegExp regex = RegExp(r"~(.+)([^\\])~", dotAll: true);

  static String transformer(String m) => m.replaceAll("~", "");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
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
  final bool spoil;
  final void Function() onSpoilerClick;
  final RegExp regex = RegExp(r"\|\|(.+)\|\|", dotAll: true);

  static String transformer(String m) => m.replaceAll("||", "");

  SpoilerTextParser(this.onSpoilerClick, {required this.spoil});

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "spoiler",
        transformer: SpoilerTextParser.transformer,
        onTap: (text) {
          onSpoilerClick();
        },
        style: TextStyle(
          backgroundColor: !spoil ? Theme.of(context).primaryColorDark : null,
          color: !spoil ? Theme.of(context).primaryColorDark : null,
        ),
      );
}

class InlineUrlTextParser implements Parser {
  final RegExp regex = RegExp(
    r"\[(.+)\]\((https?:\/\/(www\.)?)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)\)",
    dotAll: true,
  );

  static String transformer(String m) {
    return m.substring(1, m.indexOf("]"));
  }

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "inlineURL",
        onTap: (text) async {
          final uri = text.substring(text.indexOf("]") + 2, text.indexOf(")"));
          if (uri.contains("$APPLICATION_DOMAIN/$JOIN") ||
              uri.contains("$APPLICATION_DOMAIN/$SPDA") ||
              uri.contains("$APPLICATION_DOMAIN/$TEXT")) {
            await handleJoinUri(context, uri);
          } else {
            await launch(uri);
          }
        },
        transformer: InlineUrlTextParser.transformer,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      );
}

class InlineIdParser implements Parser {
  final void Function(String)? onUsernameClick;
  final RegExp regex =
      RegExp(r"\[(.+)\]\(we:\/\/user\?id=[a-zA-Z]([a-zA-Z0-9_]){4,19}\)");

  InlineIdParser({this.onUsernameClick});

  static String transformer(String m) {
    return m.substring(1, m.indexOf("]"));
  }

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
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
        style: TextStyle(color: Theme.of(context).primaryColor),
      );
}

class EmojiParser implements Parser {
  final double fontSize;
  final RegExp regex = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+',
  );

  EmojiParser({this.fontSize = 18});

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
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
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        "bot",
        onTap: (id) => onBotCommandClick(id),
        style: TextStyle(color: Theme.of(context).primaryColor),
      );
}

class SearchTermParser implements Parser {
  final String searchTerm;

  SearchTermParser(this.searchTerm);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        RegExp(searchTerm),
        "search",
        style: TextStyle(color: Theme.of(context).primaryColor),
      );
}

class Block {
  final String text;
  final bool locked;
  final void Function(String)? onTap;
  final TextStyle? style;
  final String? type;

  Block({
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
            style!,
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
  var start = 0;

  final matches = regex.allMatches(text);

  final result = <Block>[];

  for (final match in matches) {
    result
      ..add(Block(text: text.substring(start, match.start)))
      ..add(
        Block(
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
