import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/contactPic.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ChatItemToForward extends StatelessWidget {
  final Room room;

  const ChatItemToForward({Key key, this.room}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            ContactPic(true, room.roomId.uid),
            SizedBox(
              width: 12,
            ),
            Text(
              room.roomId,
              style: TextStyle(
                color: ExtraTheme.of(context).infoChat,
                fontSize: 18,
              ),
            ),
            Spacer(),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).accentColor,
              ),
              child: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                icon: Icon(
                  Icons.arrow_forward,
                  color: ExtraTheme.of(context).active,
                ),
                onPressed: null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
