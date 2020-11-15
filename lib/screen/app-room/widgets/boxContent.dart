import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply_widget_in_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BoxContent extends StatefulWidget {
  final Message message;
  final double maxWidth;

  const BoxContent({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  _BoxContentState createState() => _BoxContentState();
}

class _BoxContentState extends State<BoxContent> {
  CrossAxisAlignment last = CrossAxisAlignment.start;
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _routingServices = GetIt.I.get<RoutingService>();

  void initiaLastCross(CrossAxisAlignment c) {
    last = c;
  }

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Column(
      crossAxisAlignment: last,
      children: [
        if (widget.message.roomId.uid.category == Categories.GROUP)
          FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(widget.message.from.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return GestureDetector(
                  child: Text(
                    snapshot.data,
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    _routingServices.openRoom(widget.message.from);
                  },
                );
              } else {
                return Text(
                  "Unknown",
                  style: TextStyle(color: Colors.blue),
                );
              }
            },
          ),
        widget.message.replyToId != -1
            ? ReplyWidgetInMessage(
                roomId: widget.message.roomId,
                replyToId: widget.message.replyToId)
            : Container(),
        widget.message.forwardedFrom != null &&
                widget.message.forwardedFrom.length > 3
            ? Container(
                padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                child: FutureBuilder<String>(
                  future: _roomRepo
                      .getRoomDisplayName(widget.message.forwardedFrom.uid),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      print(snapshot.data);
                      return Text(
                          "${_appLocalization.getTraslateValue("Forwarded_From")} ${snapshot.data}",
                          style: TextStyle(color: ExtraTheme.of(context).text));
                    } else {
                      return Text(
                          "${_appLocalization.getTraslateValue("Forwarded_From")}  Unknown",
                          style: TextStyle(
                              color: ExtraTheme.of(context).secondColor));
                      ;
                    }
                  },
                ),
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
