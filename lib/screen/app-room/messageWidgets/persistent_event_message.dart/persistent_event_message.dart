import 'dart:convert';

import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class PersistentEventMessage extends StatelessWidget {
  final String content;

  const PersistentEventMessage({Key key, this.content}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: ExtraTheme.of(context).details,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: Text(
            jsonDecode(content)["text"],
            style: TextStyle(
                color: ExtraTheme.of(context).secondColor, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
