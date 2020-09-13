import 'dart:convert';
import 'package:deliver_flutter/shared/methods/isPersian.dart';

import 'package:flutter/material.dart';

class TextUi extends StatelessWidget {
  final String content;
  final double maxWidth;
  final Function lastCross;
  final bool isCaption;
  const TextUi(
      {Key key, this.content, this.maxWidth, this.lastCross, this.isCaption})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 8),
        child: Column(children: textMessages(this.content)));
  }

  List<Widget> textMessages(String content) {
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
    var joint = blocks[idx].build(this.maxWidth);

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
          blocks[idx - i].build(this.maxWidth),
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
          blocks[idx + i].build(this.maxWidth),
        ],
      );
    }

    return joint;
  }
}

List<TextBlock> preProcess(List<String> texts) {
  bool currnetLng = texts[0].isPersian();
  List<TextBlock> blocks = [TextBlock.withFirstText(texts[0])];
  for (var i = 1; i < texts.length; i++) {
    if (currnetLng == texts[i].isPersian()) {
      blocks.last.add(texts[i]);
    } else {
      currnetLng = !currnetLng;
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

  build(double maxWidth) {
    return Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[for (var i in texts) _t(_textWidget(i), maxWidth)]);
  }
}

Widget _textWidget(String text) {
  if (text.isPersian()) {
    return Text(text,
        textDirection: TextDirection.rtl, textAlign: TextAlign.justify);
  }
  return Text(text, textAlign: TextAlign.justify);
}

Widget _t(Widget text, double maxWidth) {
  return Row(
    children: <Widget>[
      Container(
          constraints: BoxConstraints.loose(Size.fromWidth(maxWidth)),
          child: text),
    ],
  );
}
