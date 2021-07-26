import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/material.dart';

class ForwardWidget extends StatelessWidget {
  final List<Message> forwardedMessages;
  final Function onClick;
  final proto.ShareUid shareUid;

  const ForwardWidget({Key key, this.forwardedMessages,this.shareUid,this.onClick}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ExtraTheme.of(context).inputBoxBackground.withAlpha(100),
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
            shareUid != null?Text(shareUid.name,style: TextStyle(color: ExtraTheme.of(context).textDetails,fontSize: 20),):
            SenderAndContent(
              messages: forwardedMessages,
              inBox: false,
                  ),
            Spacer(),
            IconButton(
              padding: EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: Icon(Icons.close, size: 18),
              onPressed: this.onClick,
            ),
          ],
        ),
      ),
    );
  }
}
