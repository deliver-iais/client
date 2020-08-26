import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/boxContent.dart';
import 'package:flutter/material.dart';

class SentMessageBox extends StatelessWidget {
  final Message message;
  final double maxWidth;

  const SentMessageBox({Key key, this.message, this.maxWidth})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).primaryColor,
          child: BoxContent(message: message, maxWidth: maxWidth),
        ),
      ),
    );
  }
}
