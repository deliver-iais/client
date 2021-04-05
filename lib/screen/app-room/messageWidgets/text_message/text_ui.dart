import 'dart:convert';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';

import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';

class TextUi extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final Function lastCross;
  final bool isSender;
  final bool isCaption;
  final bool isSeen;
  final Function onUsernameClick;
  final double imageWidth;
  final String pattern;

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
      this.imageWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 8),
        child: Column(children: textMessages()));
  }

  List<Widget> textMessages() {
    String content = "";
    if (isCaption) {
      int D = (imageWidth.round() / 12).ceil();
      content = this.message.json.toFile().caption;
      if (imageWidth != null && content.length > D) {
        List<String> d = List();
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
    texts.add(disjointThenJoin(preProcess(lines)));
    return texts;
  }

  disjointThenJoin(List<TextBlock> blocks) {
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
        this.pattern);

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
              this.pattern),
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
              this.pattern),
        ],
      );
    }
    return joint;
  }
}

List<TextBlock> preProcess(List<String> texts) {
  bool currentLang = texts[0].isPersian();
  List<TextBlock> blocks = [TextBlock.withFirstText(texts[0])];
  for (var i = 1; i < texts.length; i++) {
    if (currentLang == texts[i].isPersian()) {
      blocks.last.add(texts[i]);
    } else {
      currentLang = !currentLang;
      blocks.add(TextBlock.withFirstText(texts[i]));
    }
  }
  return blocks;
}

class TextBlock {
  bool isRtl = false;
  List<String> texts = [];
  int ml = -1;

  TextBlock.withFirstText(String text) {
    isRtl = text.isPersian();
    texts.add(text);
    ml = text.length;
  }

  add(String t) {
    if (ml < t.length) {
      ml = t.length;
    }
    texts.add(t);
  }

  build(double maxWidth, Message message, bool isLastBlock, bool isSender,
      bool isSeen, Function onUsernameClick, String pattern) {
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
                    child: _textWidget(texts[i], message, isLastBlock, isSender,
                        i, texts.length - 1, isSeen, onUsernameClick, pattern)),
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
    String pattern) {
  return Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: [
      ParsedText(
        textDirection: text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
        text: text,
        parse: <MatchText>[
          MatchText(
            pattern:
                pattern != null ? pattern : "[@#][a-zA-Z]([a-zA-Z0-9_]){4,19}",
            style: TextStyle(
              color: pattern !=null ? Colors.amber:Colors.yellowAccent,
              fontSize: 16,
            ),
            onTap: (username) {
              onClick(username);
            },
          ),
        ],
      ),
      if (i == lenght && isLastBlock)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 5),
          child: MsgTime(
            time: message.time,
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
