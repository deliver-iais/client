import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/methods/url.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';

class TextUI extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final String searchTerm;
  final Function onUsernameClick;
  final bool isBotMessage;
  final Function onBotCommandClick;

  const TextUI(
      {Key key,
      this.message,
      this.maxWidth,
      this.minWidth = 0,
      this.isSender = false,
      this.isSeen = false,
      this.searchTerm,
      this.onUsernameClick,
      this.isBotMessage = false,
      this.onBotCommandClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = extractText(message);
    List<Block> blocks = extractBlocks(text, context);
    List<TextSpan> spans = blocks.map<TextSpan>((b) {
      return TextSpan(
          text: b.text,
          style: b.style,
          recognizer: (b.onTap != null)
              ? (TapGestureRecognizer()..onTap = () => b.onTap(b.text))
              : null);
    }).toList();

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        textDirection: isSender ? TextDirection.ltr : TextDirection.rtl,
        children: [
          SelectableText.rich(
            TextSpan(
                children: spans, style: Theme.of(context).textTheme.bodyText2),
            style: Theme.of(context).textTheme.bodyText2,
            textDirection:
                text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
          ),
          TimeAndSeenStatus(
            message,
            isSender,
            isSeen,
            needsBackground: false,
            needsPositioned: false,
          )
        ],
      ),
    );
  }

  String extractText(Message msg) {
    if (msg.type == MessageType.TEXT) {
      return msg.json.toText().text;
    } else if (msg.type == MessageType.FILE) {
      return msg.json.toFile().caption;
    } else {
      return "";
    }
  }

  List<Block> extractBlocks(String text, BuildContext context) {
    List<Block> blocks = [Block(text: text)];
    List<Parser> parsers = [
      EmojiParser(),
      if (searchTerm != null && searchTerm.isNotEmpty)
        SearchTermParser(searchTerm),
      UrlParser(),
      IdParser(onUsernameClick),
      if (isBotMessage) BotCommandParser(onBotCommandClick),
      BoldTextParser(),
      ItalicTextParser()
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
      r"(https?:\/\/(www\.)?)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)");

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) =>
      parseBlocks(blocks, regex, onTap: (uri) async {
        if (uri.toString().contains(APPLICATION_DOMAIN)) {
          handleJoinUri(context, uri);
        } else
          await launch(uri);
      }, style: Theme.of(context).primaryTextTheme.bodyText2);
}

class IdParser implements Parser {
  final Function onUsernameClick;
  final RegExp regex = RegExp(r"[@][a-zA-Z]([a-zA-Z0-9_]){4,19}");

  IdParser(this.onUsernameClick);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) =>
      parseBlocks(blocks, regex,
          onTap: (id) => onUsernameClick(id),
          style: Theme.of(context).primaryTextTheme.bodyText2);
}

class BoldTextParser implements Parser {
  final RegExp regex = RegExp(r"\*\*(.+)\*\*", dotAll: true);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        transformer: (String m) => m.replaceAll("**", ""),
        style: Theme.of(context)
            .textTheme
            .bodyText2
            .copyWith(fontWeight: FontWeight.w800),
      );
}

class ItalicTextParser implements Parser {
  final RegExp regex = RegExp(r"__(.+)__", dotAll: true);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        transformer: (String m) => m.replaceAll("__", ""),
        style: Theme.of(context)
            .textTheme
            .bodyText2
            .copyWith(fontStyle: FontStyle.italic),
      );
}

class EmojiParser implements Parser {
  final double fontSize;
  final RegExp regex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+');

  EmojiParser({this.fontSize = 18});

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) => parseBlocks(
        blocks,
        regex,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
            fontSize: fontSize,
            fontFamily: "NotoColorEmoji",
            fontFamilyFallback: ["NotoColorEmoji"]),
      );
}

class BotCommandParser implements Parser {
  final Function onBotCommandClick;
  final RegExp regex = RegExp(r"[/][a-zA-Z]([a-zA-Z0-9_]){4,19}");

  BotCommandParser(this.onBotCommandClick);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) =>
      parseBlocks(blocks, regex,
          onTap: (id) => onBotCommandClick(id),
          style: Theme.of(context).primaryTextTheme.bodyText2);
}

class SearchTermParser implements Parser {
  final String searchTerm;

  SearchTermParser(this.searchTerm);

  @override
  List<Block> parse(List<Block> blocks, BuildContext context) =>
      parseBlocks(blocks, RegExp(searchTerm),
          style: Theme.of(context).primaryTextTheme.bodyText2);
}

class Block {
  final String text;
  final bool locked;
  final Function onTap;
  final TextStyle style;

  Block({this.text, this.locked = false, this.onTap, this.style});
}

List<Block> parseBlocks(List<Block> blocks, RegExp regex,
        {Function onTap, TextStyle style, Function transformer = same}) =>
    flatten(blocks.map<Iterable<Block>>((b) {
      if (b.locked) {
        return [b];
      } else {
        return parseText(b.text, regex, onTap, style, transformer: transformer);
      }
    })).toList();

List<Block> parseText(
    String text, RegExp regex, Function onTap, TextStyle style,
    {Function transformer = same}) {
  var start = 0;

  Iterable<RegExpMatch> matches = regex.allMatches(text);

  var result = <Block>[];

  for (var match in matches) {
    result.add(Block(text: transformer(text.substring(start, match.start))));
    result.add(Block(
        text: transformer(match[0]), onTap: onTap, style: style, locked: true));
    start = match.end;
  }

  result.add(Block(text: transformer(text.substring(start))));

  return result;
}

same(m) => m;

Iterable<T> flatten<T>(Iterable<Iterable<T>> items) sync* {
  for (var i in items) {
    yield* i;
  }
}
