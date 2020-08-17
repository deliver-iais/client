import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class LastMessage extends StatelessWidget {
  final Message message;

  const LastMessage({Key key, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String data;
    // print('hello');
    TextDirection td;
    if (message.type.index == MessageType.text.index) {
      // print(message.json);
      String oneLine = (message.json.toText().text.split('\n'))[0];
      if (oneLine.isPersian()) {
        td = TextDirection.rtl;
      } else
        td = TextDirection.ltr;
      // data = oneLine + ' ...';
      data = oneLine;
    } else {
      td = TextDirection.ltr;
      data = 'Photo';
    }

    return Text(
      data,
      maxLines: 1,
      textDirection: td,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ExtraTheme.of(context).infoChat,
        fontSize: 13,
      ),
    );
  }
}
