import 'package:deliver/box/message.dart';

import 'package:deliver/box/message_type.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_buttons_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_form_message.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_result.dart';
import 'package:deliver/screen/room/messageWidgets/live_location_message.dart';

import 'package:deliver/screen/room/messageWidgets/locatioin_message.dart';
import 'package:deliver/screen/room/messageWidgets/file_message_ui.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/reply_brief.dart';
import 'package:deliver/screen/room/messageWidgets/sticker_messge_widget.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/widgets/share_private_data_accept_message_widget.dart';
import 'package:deliver/screen/room/widgets/share_private_data_request_message_widget.dart';
import 'package:deliver/screen/room/widgets/share_uid_message_widget.dart';

import 'package:deliver/services/routing_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class BoxContent extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final Function scrollToMessage;
  final bool isSeen;
  final Function? onUsernameClick;
  final String? pattern;
  final Function? onBotCommandClick;

  const BoxContent(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.minWidth,
      required this.isSender,
      required this.isSeen,
      this.pattern,
      this.onUsernameClick,
      this.onBotCommandClick,
      required this.scrollToMessage})
      : super(key: key);

  @override
  _BoxContentState createState() => _BoxContentState();
}

class _BoxContentState extends State<BoxContent> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.roomUid.asUid().category == Categories.GROUP &&
                !widget.isSender)
              senderNameBox(),
            if (hasReply()) replyToIdBox(),
            if (widget.message.forwardedFrom != null &&
                widget.message.forwardedFrom!.length > 3)
              forwardedFromBox(),
            messageBox()
          ],
        ),
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
          replyToId: widget.message.replyToId!,
          maxWidth: widget.minWidth,
          color: (widget.isSender
                  ? Color.lerp(ExtraTheme.of(context).sentMessageBox,
                      Theme.of(context).dividerColor, 0.05)
                  : Color.lerp(ExtraTheme.of(context).receivedMessageBox,
                      Theme.of(context).dividerColor, 0.05)) ??
              Colors.transparent,
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
            return showName(snapshot.data!);
          } else {
            return const Text("");
          }
        },
      ),
    );
  }

  Widget showName(String name) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          constraints:
              BoxConstraints.loose(Size.fromWidth(widget.minWidth - 16)),
          child: Text(
            name.trim(),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).primaryTextTheme.bodyText2,
          ),
        ),
        onTap: () {
          _routingServices.openRoom(widget.message.from);
        },
      ),
    );
  }

  Widget forwardedFromBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      padding: const EdgeInsets.only(left: 4, right: 8, top: 2, bottom: 0),
      constraints: BoxConstraints.loose(Size.fromWidth(widget.minWidth - 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).buttonTheme.colorScheme?.primary,
      ),
      child: FutureBuilder<String>(
        future: _roomRepo.getName(widget.message.forwardedFrom!.asUid()),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_arrow_right_rounded,
                      size: 15,
                      color:
                          Theme.of(context).buttonTheme.colorScheme?.onPrimary),
                  Flexible(
                    child: Text(snapshot.data ?? "",
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            color: Theme.of(context)
                                .buttonTheme
                                .colorScheme
                                ?.onPrimary,
                            fontSize: 12)),
                  ),
                ],
              ),
              onTap: () {
                _routingServices.openRoom(widget.message.forwardedFrom!);
              },
            ),
          );
        },
      ),
    );
  }

  Widget messageBox() {
    if (AnimatedEmoji.isAnimatedEmoji(widget.message)) {
      return AnimatedEmoji(
        message: widget.message,
        isSeen: widget.isSeen,
      );
    }

    switch (widget.message.type) {
      case MessageType.TEXT:
        return TextUI(
          message: widget.message,
          maxWidth: widget.maxWidth,
          minWidth: widget.minWidth,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          searchTerm: widget.pattern,
          onUsernameClick: widget.onUsernameClick!,
          isBotMessage: widget.message.from.asUid().category == Categories.BOT,
          onBotCommandClick: widget.onBotCommandClick,
        );
      case MessageType.FILE:
        return FileMessageUi(
          message: widget.message,
          maxWidth: widget.maxWidth,
          minWidth: widget.minWidth,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
        );

      case MessageType.STICKER:
        return StickerMessageWidget(
            widget.message, widget.isSender, widget.isSeen);

      case MessageType.LOCATION:
        return LocationMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );

      case MessageType.LIVE_LOCATION:
        return LiveLocationMessageWidget(
            widget.message, widget.isSender, widget.isSeen);

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
      case MessageType.PERSISTENT_EVENT:
        // we show peristant event message in roompage
        break;
      case MessageType.SHARE_UID:
        return ShareUidMessageWidget(
          message: widget.message,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
        );
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        return SharePrivateDataRequestMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        return SharePrivateDataAcceptMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
        );
      case MessageType.NOT_SET:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
    return Container();
  }

  bool hasReply() {
    return widget.message.to.asUid().category != Categories.BOT &&
        widget.message.replyToId != null &&
        widget.message.replyToId! > 0;
  }
}
