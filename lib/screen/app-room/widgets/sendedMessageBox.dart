import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final isGroup;

  const SentMessageBox({Key key, this.message, this.maxWidth, this.isGroup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Container(
              padding: const EdgeInsets.all(2),
              color: Theme.of(context).primaryColor,
              child: BoxContent(message: message, maxWidth: maxWidth),
            ),
          ),
        ),
        if (this.isGroup)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2.0, right: 8.0),
            child: CircleAvatarWidget(message.from.uid, 18),
          ),
      ],
    );
  }
}
