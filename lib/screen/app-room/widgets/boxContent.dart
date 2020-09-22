import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply_widget_in_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class BoxContent extends StatefulWidget {
  final Message message;
  final double maxWidth;

  const BoxContent({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  _BoxContentState createState() => _BoxContentState();
}

class _BoxContentState extends State<BoxContent> {
  CrossAxisAlignment last = CrossAxisAlignment.start;

  void initiaLastCross(CrossAxisAlignment c) {
    last = c;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.message);
    return Column(
      crossAxisAlignment: last,
      children: [
        widget.message.replyToId != -1
            ? ReplyWidgetInMessage(
                roomId: widget.message.roomId,
                replyToId: widget.message.replyToId)
            : Container(),
        widget.message.forwardedFrom != null
            ? Container(
                padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Text(
                    'Forwarded message\nFrom ' +
                        widget.message.forwardedFrom.substring(0, 5),
                    style:
                        TextStyle(color: ExtraTheme.of(context).secondColor)),
              )
            : Container(),
        widget.message.type == MessageType.TEXT
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
                child: TextUi(
                  content: widget.message.json.toText().text,
                  maxWidth: widget.maxWidth,
                  isCaption: false,
                ),
              )
            : widget.message.type == MessageType.FILE
                ? MessageUi(
                    message: widget.message,
                    maxWidth: widget.maxWidth,
                    lastCross: initiaLastCross,
                    last: last)
                : Container()
      ],
    );
  }
}
