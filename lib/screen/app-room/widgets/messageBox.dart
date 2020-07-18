import 'dart:convert';

import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final String loggedinUserId;
  final Message message;
  final double maxWidth;

  const MessageBox({Key key, this.loggedinUserId, this.message, this.maxWidth})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<String> lines = LineSplitter().convert(message.content);
    List<Text> texts = [];
    for (var i = 0; i < lines.length; i++) {
      texts.add(
        Text(
          lines[i],
          textDirection:
              isPersian(lines[i]) ? TextDirection.rtl : TextDirection.ltr,
        ),
      );
    }
    return Row(
      mainAxisAlignment: message.from == loggedinUserId
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: message.from == loggedinUserId
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).accentColor,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: texts,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isPersian(String value) {
    RegExp exp = new RegExp(r"^([\u0600-\u06FF]+\s?)+$");
    return exp.hasMatch(value.trim());
  }
}
