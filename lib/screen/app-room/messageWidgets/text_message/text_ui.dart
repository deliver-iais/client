import 'dart:convert';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';

import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class TextUi extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final Function lastCross;
  final bool isSender;
  final bool isCaption;

  const TextUi(
      {Key key,
      this.message,
      this.maxWidth,
      this.lastCross,
      this.isSender,
      this.isCaption})
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
      content = this.message.json.toFile().caption;
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
        this.maxWidth, this.message, idx == (blocks.length - 1), this.isSender);

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
          blocks[idx - i].build(this.maxWidth, this.message,
              i == (blocks.length - 1), this.isSender),
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
          blocks[idx + i].build(this.maxWidth, this.message,
              i == (blocks.length - 1), this.isSender),
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

  build(double maxWidth, Message message, bool isLastBlock, bool isSender) {
    return Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          for (var i in texts)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                    constraints: BoxConstraints.loose(Size.fromWidth(maxWidth)),
                    child: _textWidget(i, message, isLastBlock, isSender)),
              ],
            )
        ]);
  }
}

Widget _textWidget(
    String text, Message message, bool isLastBlock, bool isSender) {
  return Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.start,
    children: [
      Text(text,
          textDirection:
              text.isPersian() ? TextDirection.rtl : TextDirection.ltr,
          textAlign: TextAlign.justify),
      if (isLastBlock)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 5),
          child: MsgTime(
            time: message.time,
          ),
        ),
      if (isLastBlock & isSender)
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 5),
          child: SeenStatus(message),
        ),
    ],
  );
}
