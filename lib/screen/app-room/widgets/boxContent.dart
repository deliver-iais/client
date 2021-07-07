import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';

import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/bot_buttons_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/bot_form_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/bot_sended_form_widget.dart';

import 'package:deliver_flutter/screen/app-room/messageWidgets/locatioin_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply_widget_in_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/stickerMessgeWidget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sharePrivateDataAcceptMessageWidget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sharePrivateDataRequestMessageWidget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_uid_message_widget.dart';

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
  final String pattern;
  final Function onBotCommandClick;

  const BoxContent(
      {Key key,
      this.message,
      this.maxWidth,
      this.isSender,
      this.isSeen,
      this.pattern,
      this.onUsernameClick,
      this.onBotCommandClick,
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
        if (widget.message.roomUid.asUid().category == Categories.GROUP &&
            !widget.isSender)
          SizedBox(height: 20, child: senderNameBox()),
        if (widget.message.to.asUid().category != Categories.BOT &&
            widget.message.replyToId != null &&
            widget.message.replyToId > 0)
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
        roomId: widget.message.roomUid,
        replyToId: widget.message.replyToId,
      ),
    );
  }

  Widget senderNameBox() {
    return FutureBuilder<String>(
      future: _roomRepo.getName(widget.message.from.asUid()),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return showName(snapshot.data);
        } else {
          return Text(
            " ",
            style: TextStyle(color: Colors.blue),
          );
        }
      },
    );
  }

  GestureDetector showName(String name) {
    return GestureDetector(
      child: Text(
        name,
        style: TextStyle(color: Colors.blue, fontSize: 15),
      ),
      onTap: () {
        _routingServices.openRoom(widget.message.from);
      },
    );
  }

  Widget forwardedFromBox() {
    return Container(
      padding: EdgeInsets.only(top: 8, left: 8, right: 8),
      child: FutureBuilder<String>(
        future: _roomRepo.getName(widget.message.forwardedFrom.asUid()),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return GestureDetector(
              child: Text(
                  "${_appLocalization.getTraslateValue("Forwarded_From")} ${snapshot.data}",
                  style: TextStyle(
                      color: ExtraTheme.of(context).messageDetails,
                      fontSize: 13)),
              onTap: () {
                _routingServices.openRoom(widget.message.forwardedFrom);
              },
            );
          } else {
            return Text(
                "${_appLocalization.getTraslateValue("Forwarded_From")} Unknown",
                style: TextStyle(
                    color: ExtraTheme.of(context).messageDetails,
                    fontSize: 13));
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
            pattern: widget.pattern,
            message: widget.message,
            maxWidth: widget.maxWidth,
            isSender: widget.isSender,
            isCaption: false,
            isBotMessage:
                widget.message.from.asUid().category == Categories.BOT,
            onBotCommandClick: widget.onBotCommandClick,
            onUsernameClick: widget.onUsernameClick,
            isSeen: widget.isSeen,
            color: ExtraTheme.of(context).textMessage,
          ),
        );
        break;
      case MessageType.FILE:
        return FileMessageUi(
          message: widget.message,
          maxWidth: widget.maxWidth,
          lastCross: initialLastCross,
          isSender: widget.isSender,
          last: last,
          isSeen: widget.isSeen,
        );
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
      case MessageType.FORM_RESULT:
        return BotSentFormWidget(
            message: widget.message, isSeen: widget.isSeen);
      case MessageType.FORM:
        return BotFormMessage(message: widget.message, isSeen: true);
      case MessageType.BUTTONS:
        return BotButtonsWidget(message: widget.message);
        break;
      case MessageType.PERSISTENT_EVENT:
        // we show peristant event message in roompage
        break;
      case MessageType.SHARE_UID:
        return ShareUidMessageWidget(
          message: widget.message,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
        );
        break;
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        return SharePrivateDataRequestMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        return SharePrivateDataAcceptMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );

        break;
      case MessageType.NOT_SET:
        // TODO: Handle this case.
        break;
    }
    return Container();
  }
}
