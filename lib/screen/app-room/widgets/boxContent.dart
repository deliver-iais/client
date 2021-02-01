import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/bot_sended_form_widget.dart';
import 'file:///F:/deliver-flutter3/lib/screen/app-room/messageWidgets/botMessageWidget/bot_form_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/locatioin_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply_widget_in_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/stickerMessgeWidget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/map_widget.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class BoxContent extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final Function scrollToMessage;
  final bool isSeen;
  final Function onUsernameClick;

  const BoxContent(
      {Key key,
      this.message,
      this.maxWidth,
      this.isSender,
      this.isSeen,
      this.onUsernameClick,
      this.scrollToMessage})
      : super(key: key);

  @override
  _BoxContentState createState() => _BoxContentState();
}

class _BoxContentState extends State<BoxContent> {
  CrossAxisAlignment last = CrossAxisAlignment.start;
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _routingServices = GetIt.I.get<RoutingService>();

  void initialLastCross(CrossAxisAlignment c) {
    last = c;
  }

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Column(
      crossAxisAlignment: last,
      children: [
        if (widget.message.roomId.uid.category == Categories.GROUP &&
            !widget.isSender)
          senderNameBox(),
        if (widget.message.to.getUid().category != Categories.BOT &&  widget.message.replyToId != null && widget.message.replyToId > 0)
          replyToIdBox(),
        if (widget.message.forwardedFrom != null &&
            widget.message.forwardedFrom.length > 3)
          forwardedFromBox(),
        messageBox()
      ],
    );
  }

  Widget replyToIdBox() {
    return GestureDetector(
      onTap: () {
        widget.scrollToMessage(widget.message.replyToId);
      },
      child: ReplyWidgetInMessage(
        roomId: widget.message.roomId,
        replyToId: widget.message.replyToId,
      ),
    );
  }

  Widget senderNameBox() {
    return FutureBuilder<String>(
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
    );
  }

  Widget forwardedFromBox() {
    return Container(
      padding: EdgeInsets.only(top: 8, left: 8, right: 8),
      child: FutureBuilder<String>(
        future: _roomRepo.getRoomDisplayName(widget.message.forwardedFrom.uid),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return GestureDetector(
              child: Text(
                  "${_appLocalization.getTraslateValue("Forwarded_From")} ${snapshot.data}",
                  style: TextStyle(color: ExtraTheme.of(context).text)),
              onTap: () {
                _routingServices.openRoom(widget.message.forwardedFrom);
              },
            );
          } else {
            return Text(
                "${_appLocalization.getTraslateValue("Forwarded_From")} Unknown",
                style: TextStyle(color: ExtraTheme.of(context).secondColor));
          }
        },
      ),
    );
  }

  Widget messageBox() {
    switch (widget.message.type) {
      case MessageType.TEXT:
        return Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
          child: TextUi(
            message: widget.message,
            maxWidth: widget.maxWidth,
            isSender: widget.isSender,
            isCaption: false,
            onUsernameClick: widget.onUsernameClick,
            isSeen: widget.isSeen,
          ),
        );
        break;
      case MessageType.FILE:
        return FileMessageUi(
            message: widget.message,
            maxWidth: widget.maxWidth,
            lastCross: initialLastCross,
            isSender: widget.isSender,
            last: last);
        break;
      case MessageType.STICKER:
        return StickerMessageWidget(
            widget.message, widget.isSender, widget.isSeen);
        break;
      case MessageType.LOCATION:
        return LocationMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );
        break;
      case MessageType.LIVE_LOCATION:
        // TODO: Handle this case.
        break;
      case MessageType.POLL:
        // TODO: Handle this case.
        break;
      case MessageType.FORM:
        if(widget.isSender){
          BotSendedFormWidget(message: widget.message,);
        }
        else{
        return  BotFormMessage(message: widget.message,);
        }

        break;
      case MessageType.PERSISTENT_EVENT:
        // TODO: Handle this case.
        break;
      case MessageType.NOT_SET:
        // TODO: Handle this case.
        break;
    }
    return Container();
  }
}
