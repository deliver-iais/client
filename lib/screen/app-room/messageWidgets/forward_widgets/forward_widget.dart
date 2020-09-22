import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/sender_and_content.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class ForwardWidget extends StatelessWidget {
  final List<Message> forwardedMessages;

  const ForwardWidget({Key key, this.forwardedMessages}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ExtraTheme.of(context).secondColor,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward,
              color: Theme.of(context).primaryColor,
              size: 25,
            ),
            SizedBox(width: 10),
            SenderAndContent(
              messages: forwardedMessages,
              inBox: false,
            ),
            Spacer(),
            IconButton(
              padding: EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: Icon(Icons.close, size: 18),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
