import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';

import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/botMessageWidget/bot_buttons_widget.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/botMessageWidget/bot_form_message.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/botMessageWidget/formResult.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/live_location_message.dart';

import 'package:deliver_flutter/screen/room/messageWidgets/locatioin_message.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/message_ui.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/reply_widgets/reply_brief.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/stickerMessgeWidget.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver_flutter/screen/room/widgets/sharePrivateDataAcceptMessageWidget.dart';
import 'package:deliver_flutter/screen/room/widgets/sharePrivateDataRequestMessageWidget.dart';
import 'package:deliver_flutter/screen/room/widgets/share_uid_message_widget.dart';

import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
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
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _routingServices = GetIt.I.get<RoutingService>();

  I18N _i18n;

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.roomUid.asUid().category == Categories.GROUP &&
              !widget.isSender)
            senderNameBox(),
          if (hasReply()) replyToIdBox(),
          if (widget.message.forwardedFrom != null &&
              widget.message.forwardedFrom.length > 3)
            forwardedFromBox(),
          messageBox()
        ],
      ),
    );
  }

  Widget replyToIdBox() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.scrollToMessage(widget.message.replyToId);
        },
        child: ReplyBrief(
          roomId: widget.message.roomUid,
          replyToId: widget.message.replyToId,
        ),
      ),
    );
  }

  Widget senderNameBox() {
    return Container(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 2, bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.isSender
            ? ExtraTheme.of(context).sentMessageBox
            : ExtraTheme.of(context).receivedMessageBox,
      ),
      child: FutureBuilder<String>(
        future: _roomRepo.getName(widget.message.from.asUid()),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return showName(snapshot.data);
          } else {
            return Text("");
          }
        },
      ),
    );
  }

  Widget showName(String name) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Text(
          name.trim(),
          style: Theme.of(context).primaryTextTheme.bodyText2,
        ),
        onTap: () {
          _routingServices.openRoom(widget.message.from);
        },
      ),
    );
  }

  Widget forwardedFromBox() {
    return Container(
      padding: EdgeInsets.all(4),
      child: FutureBuilder<String>(
        future: _roomRepo.getName(widget.message.forwardedFrom.asUid()),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return GestureDetector(
              child: Text("${_i18n.get("Forwarded_From")} ${snapshot.data}",
                  style: TextStyle(
                      color: ExtraTheme.of(context).messageDetails,
                      fontSize: 13)),
              onTap: () {
                _routingServices.openRoom(widget.message.forwardedFrom);
              },
            );
          } else {
            return Text("${_i18n.get("Forwarded_From")} Unknown",
                style: TextStyle(
                    color: ExtraTheme.of(context).messageDetails,
                    fontSize: 13));
          }
        },
      ),
    );
  }

  Widget messageBox() {
    if (AnimatedEmoji.isAnimatedEmoji(widget.message))
      return AnimatedEmoji(
        message: widget.message,
        isSeen: widget.isSeen,
      );

    switch (widget.message.type) {
      case MessageType.TEXT:
        return TextUI(
          message: widget.message,
          maxWidth: widget.maxWidth,
          minWidth: hasReply() ? 200 : 0,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          searchTerm: widget.pattern,
          onUsernameClick: widget.onUsernameClick,
          isBotMessage: widget.message.from.asUid().category == Categories.BOT,
          onBotCommandClick: widget.onBotCommandClick,
        );
        break;
      case MessageType.FILE:
        return FileMessageUi(
          message: widget.message,
          maxWidth: widget.maxWidth,
          isSender: widget.isSender,
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
        return LiveLocationMessageWidget(
            widget.message, widget.isSender, widget.isSeen);
        break;
      case MessageType.POLL:
        // TODO: Handle this case.
        break;
      case MessageType.FORM_RESULT:
        return FormResultWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );
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

  bool hasReply() {
    return widget.message.to.asUid().category != Categories.BOT &&
        widget.message.replyToId != null &&
        widget.message.replyToId > 0;
  }
}
