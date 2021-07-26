import 'dart:convert';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:deliver_flutter/shared/methods/time.dart';
import 'package:deliver_flutter/shared/methods/url.dart';
import 'package:deliver_flutter/shared/widgets/seen_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart';

class TextUi extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final Function lastCross;
  final bool isSender;
  final bool isCaption;
  final bool isSeen;
  final bool isBotMessage;
  final Function onUsernameClick;
  final double imageWidth;
  final String pattern;
  final Function onBotCommandClick;
  final Color color;

  const TextUi(
      {Key key,
      this.message,
      this.maxWidth,
      this.lastCross,
      this.isSender,
      this.isSeen,
      this.onUsernameClick,
      this.isCaption,
      this.pattern,
      this.onBotCommandClick,
      this.isBotMessage = false,
      this.imageWidth,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 8),
        child: Column(children: textMessages(context)));
  }

  List<Widget> textMessages(BuildContext context) {
    String content = "";
    if (isCaption) {
      int D = (imageWidth.round() / 12).ceil();
      content = this.message.json.toFile().caption;
      if (imageWidth != null && content.length > D) {
        List<String> d = [];
        int u = (content.length / D).ceil();
        int i = 0;
        while (i < u) {
          d.add(content.substring(
              (i * D) < content.length ? (i * D) : content.length,
              (i + 1) * (D) < content.length ? (i + 1) * D : content.length));
          i = i + 1;
        }
        content = "";
        d.forEach((element) {
          if (!element.contains("\n")) element = element + "\n";
          content = content + element;
        });
      }
    } else {
      content = this.message.json.toText().text;
    }
    List<String> lines = LineSplitter().convert(content);
    List<Widget> texts = [];
    texts.add(disjointThenJoin(preProcess(lines, color), context));
    return texts;
  }

  disjointThenJoin(List<TextBlock> blocks, BuildContext context) {
    var idx = 0;
    var m = 0;
    for (var i = 0; i < blocks.length; i++) {
      var b = blocks[i];
      if (b.ml > m) {
        m = b.ml;
        idx = i;
      }
    }

    if (isCaption)
      lastCross(blocks[idx].isRtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start);
    //max lenght
    var joint = blocks[idx].build(
        this.maxWidth,
        this.message,
        idx == (blocks.length - 1),
        this.isSender,
        this.isSeen,
        this.onUsernameClick,
        this.pattern,
        this.onBotCommandClick,
        context,
        isBotMessage: isBotMessage);

    for (var i = 1; i <= idx; i++) {
      joint = Column(
        crossAxisAlignment: blocks[idx].isRtl
            ? (blocks[idx].isRtl == blocks[idx - i].isRtl
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start)
            : (blocks[idx].isRtl == blocks[idx - i].isRtl
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end),
        children: <Widget>[
          blocks[idx - i].build(
              this.maxWidth,
              this.message,
              idx - i == (blocks.length - 1),
              this.isSender,
              this.isSeen,
              this.onUsernameClick,
              this.pattern,
              this.onBotCommandClick,
              context,
              isBotMessage: isBotMessage),
          joint,
        ],
      );
    }
    for (var i = 1; i < blocks.length - idx; i++) {
      joint = Column(
        crossAxisAlignment: blocks[idx].isRtl
            ? (blocks[idx].isRtl == blocks[idx + i].isRtl
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start)
            : (blocks[idx].isRtl == blocks[idx + i].isRtl
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end),
        children: <Widget>[
          joint,
          blocks[idx + i].build(
              this.maxWidth,
              this.message,
              idx + i == (blocks.length - 1),
              this.isSender,
              this.isSeen,
              this.onUsernameClick,
              this.pattern,
              this.onBotCommandClick,
              context,
              isBotMessage: isBotMessage),
        ],
      );
    }
    return joint;
  }
}

List<TextBlock> preProcess(List<String> texts, Color color) {
  if (texts.length <= 0) {
    return [TextBlock.withFirstText("", color)];
  }
  bool currentLang = texts[0].isPersian();
  List<TextBlock> blocks = [TextBlock.withFirstText(texts[0], color)];
  for (var i = 1; i < texts.length; i++) {
    if (currentLang == texts[i].isPersian()) {
      blocks.last.add(texts[i]);
    } else {
      currentLang = !currentLang;
      blocks.add(TextBlock.withFirstText(texts[i], color));
    }
  }
  return blocks;
}

class TextBlock {
  bool isRtl = false;
  List<String> texts = [];
  int ml = -1;
  Color color;

  TextBlock.withFirstText(String text, Color color) {
    isRtl = text.isPersian();
    texts.add(text);
    ml = text.length;
    this.color = color;
  }

  add(String t) {
    if (ml < t.length) {
      ml = t.length;
    }
    texts.add(t);
  }

  build(
      double maxWidth,
      Message message,
      bool isLastBlock,
      bool isSender,
      bool isSeen,
      Function onUsernameClick,
      String pattern,
      Function onBotCommandClick,
      BuildContext context,
      {isBotMessage = false}) {
    return Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < texts.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                    constraints: BoxConstraints.loose(Size.fromWidth(maxWidth)),
                    child: _textWidget(
                        texts[i],
                        message,
                        isLastBlock,
                        isSender,
                        i,
                        texts.length - 1,
                        isSeen,
                        onUsernameClick,
                        pattern,
                        onBotCommandClick,
                        this.color,
                        context,
                        isBotMessage: isBotMessage)),
              ],
            )
        ]);
  }
}

Widget _textWidget(
    String text,
    Message message,
    bool isLastBlock,
    bool isSender,
    i,
    int lenght,
    bool isSeen,
    Function onClick,
    String pattern,
    Function onBotCommandClick,
    Color color,
    BuildContext context,
    {bool isBotMessage = false}) {
  return Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: [
      ParsedText(
        textDirection: text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
        text: text,
        style: TextStyle(color: color, fontSize: 16),
        parse: <MatchText>[
          MatchText(
            type: ParsedType.CUSTOM,
            pattern:
                r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)",
            style: TextStyle(
              color: ExtraTheme.of(context).username,
              fontSize: 16,
            ),
            onTap: (uri) async {
              if (uri.toString().contains("deliver-co")) {
                handleJoinUri(context, uri);
              } else
                await launch(uri);
            },
          ),
          MatchText(
            type: ParsedType.CUSTOM,
            pattern:
                pattern != null ? pattern : "[@#][a-zA-Z]([a-zA-Z0-9_]){4,19}",
            style: TextStyle(
              color: ExtraTheme.of(context).username,
              fontSize: 16,
            ),
            onTap: (username) async {
              onClick(username);
            },
          ),
          if (isBotMessage)
            MatchText(
              type: ParsedType.CUSTOM,
              pattern:
                  pattern != null ? pattern : "[/][a-zA-Z]([a-zA-Z0-9_]){4,19}",
              style: TextStyle(
                color: ExtraTheme.of(context).username,
                fontSize: 16,
              ),
              onTap: (username) async {
                onBotCommandClick(username);
              },
            ),
          MatchText(
            type: ParsedType.PHONE,
            style: TextStyle(
              color: ExtraTheme.of(context).username,
              fontSize: 16,
            ),
            onTap: (phone) async {
              await launch("tel:$phone");
            },
          ),
        ],
      ),
      if (i == lenght && isLastBlock)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 5),
          child: MsgTime(
            time: date(message.time),
          ),
        ),
      if (i == lenght && isLastBlock & isSender)
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 5),
          child: SeenStatus(
            message,
            isSeen: isSeen,
          ),
        ),
    ],
  );
}
