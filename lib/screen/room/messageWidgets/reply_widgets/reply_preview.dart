import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class ReplyPreview extends StatelessWidget {
  final Message message;
  final Function() resetRoomPageDetails;

  const ReplyPreview(
      {Key? key, required this.message, required this.resetRoomPageDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ExtraTheme.of(context).inputBoxBackground.withAlpha(200),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.reply,
              color: Theme.of(context).primaryColor,
              size: 25,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SenderAndContent(
                  messages: List<Message>.filled(1, message),
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: const Icon(Icons.close, size: 18),
              onPressed: resetRoomPageDetails,
            ),
          ],
        ),
      ),
    );
  }
}
