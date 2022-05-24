import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/animation_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_buttons_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_form_message.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_table_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_result.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_message_widget.dart';
import 'package:deliver/screen/room/messageWidgets/file_message_ui.dart';
import 'package:deliver/screen/room/messageWidgets/live_location_message.dart';
import 'package:deliver/screen/room/messageWidgets/location_message.dart';
import 'package:deliver/screen/room/messageWidgets/not_supported_message.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/reply_brief.dart';
import 'package:deliver/screen/room/messageWidgets/sticker_messge_widget.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/widgets/share_private_data_accept_message_widget.dart';
import 'package:deliver/screen/room/widgets/share_private_data_request_message_widget.dart';
import 'package:deliver/screen/room/widgets/share_uid_message_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class BoxContent extends StatefulWidget {
  final Message message;
  final MessageReplyBrief? messageReplyBrief;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final bool isFirstMessageInGroupedMessages;
  final CustomColorScheme colorScheme;
  final String? pattern;
  final void Function(TapDownDetails) storePosition;
  final void Function(String) onUsernameClick;
  final void Function(String) onBotCommandClick;
  final void Function(int, int) scrollToMessage;
  final void Function() onArrowIconClick;
  final void Function() onEdit;

  const BoxContent({
    Key? key,
    required this.message,
    required this.maxWidth,
    required this.minWidth,
    required this.isSender,
    required this.isSeen,
    required this.onBotCommandClick,
    required this.isFirstMessageInGroupedMessages,
    required this.scrollToMessage,
    required this.onArrowIconClick,
    required this.colorScheme,
    required this.storePosition,
    required this.onUsernameClick,
    this.pattern,
    this.messageReplyBrief,
    required this.onEdit,
  }) : super(key: key);

  Type getState() {
    return _BoxContentState;
  }

  @override
  _BoxContentState createState() => _BoxContentState();
}

class _BoxContentState extends State<BoxContent> {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  bool hideArrowDopIcon = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (s) {
        hideArrowDopIcon = false;
        setState(() {});
      },
      onExit: (s) {
        hideArrowDopIcon = true;
        setState(() {});
      },
      child: Stack(
        alignment: widget.isSender ? Alignment.topLeft : Alignment.topRight,
        children: [
          RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDebugEnabled())
                  DebugC(
                    label: "message details",
                    children: [
                      Debug(widget.message.id, label: "id"),
                      Debug(widget.message.packetId, label: "packetId"),
                      Debug(widget.message.json, label: "json"),
                    ],
                  ),
                if (shouldShowSenderName()) senderNameBox(widget.colorScheme),
                if (hasReply()) replyToIdBox(),
                if (isForwarded()) forwardedFromBox(),
                messageBox()
              ],
            ),
          ),
          if (isDesktop | isWeb)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (tapDownDetails) {
                  widget.storePosition(tapDownDetails);
                },
                onTap: () => widget.onArrowIconClick(),
                child: AnimatedOpacity(
                  opacity: !hideArrowDopIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    child: const BlurContainer(
                      padding: EdgeInsets.all(3),
                      child: Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget replyToIdBox() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.scrollToMessage(
            widget.message.replyToId,
            widget.message.id ?? 0,
          );
        },
        child: ReplyBrief(
          roomId: widget.message.roomUid,
          replyToId: widget.message.replyToId,
          messageReplyBrief: widget.messageReplyBrief,
          maxWidth: widget.minWidth,
          backgroundColor: widget.colorScheme.onPrimary,
          foregroundColor: widget.colorScheme.primary,
        ),
      ),
    );
  }

  Widget forwardedFromBox() {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 2),
      constraints: BoxConstraints.loose(Size.fromWidth(widget.minWidth - 16)),
      decoration: BoxDecoration(
        borderRadius: secondaryBorder,
        color: widget.colorScheme.primary,
      ),
      child: FutureBuilder<String>(
        future: _roomRepo.getName(widget.message.forwardedFrom!.asUid()),
        builder: (context, snapshot) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.arrowshape_turn_up_right,
                    size: 15,
                    color: widget.colorScheme.onPrimary,
                  ),
                  Flexible(
                    child: Text(
                      snapshot.data ?? "",
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: widget.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
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
        colorScheme: widget.colorScheme,
      );
    }

    switch (widget.message.type) {
      case MessageType.TEXT:
        return TextUI(
          message: widget.message,
          maxWidth: widget.maxWidth,
          minWidth: isForwarded() || hasReply() || shouldShowSenderName()
              ? widget.minWidth
              : 0,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          colorScheme: widget.colorScheme,
          searchTerm: widget.pattern,
          onUsernameClick: widget.onUsernameClick,
          onBotCommandClick: widget.onBotCommandClick,
        );
      case MessageType.FILE:
        return FileMessageUi(
          message: widget.message,
          maxWidth: widget.maxWidth,
          minWidth: widget.minWidth,
          onUsernameClick: widget.onUsernameClick,
          colorScheme: widget.colorScheme,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          onEdit: widget.onEdit,
        );

      case MessageType.STICKER:
        return StickerMessageWidget(
          widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );

      case MessageType.LOCATION:
        return LocationMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );

      case MessageType.LIVE_LOCATION:
        return LiveLocationMessageWidget(
          widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );

      case MessageType.POLL:
        break;
      case MessageType.FORM_RESULT:
        return FormResultWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );
      case MessageType.FORM:
        return BotFormMessage(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );
      case MessageType.BUTTONS:
        return BotButtonsWidget(
          message: widget.message,
          maxWidth: widget.maxWidth * 0.85,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );
      case MessageType.TABLE:
        return BotTableWidget(
          message: widget.message,
          colorScheme: widget.colorScheme,
        );
      case MessageType.SHARE_UID:
        return ShareUidMessageWidget(
          message: widget.message,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          colorScheme: widget.colorScheme,
        );
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        return SharePrivateDataRequestMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          maxWidth: widget.maxWidth * 0.75,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        return SharePrivateDataAcceptMessageWidget(
          message: widget.message,
          isSeen: widget.isSeen,
          isSender: widget.isSender,
          colorScheme: widget.colorScheme,
        );
      case MessageType.CALL:
        return CallMessageWidget(
          message: widget.message,
          colorScheme: widget.colorScheme,
        );
      case MessageType.NOT_SET:
        return NotSupportedMessage(
          maxWidth: widget.maxWidth,
          colorScheme: widget.colorScheme,
        );
      case MessageType.PERSISTENT_EVENT:
        // we show persistent event message in room page
        break;
    }
    return Container();
  }

  bool hasReply() {
    return widget.message.to.asUid().category != Categories.BOT &&
        widget.message.replyToId > 0;
  }

  bool isForwarded() {
    return (widget.message.forwardedFrom?.length ?? 0) > 3;
  }

  bool shouldShowSenderName() {
    return !widget.isSender &&
        widget.isFirstMessageInGroupedMessages &&
        widget.message.roomUid.asUid().category == Categories.GROUP;
  }

  Widget senderNameBox(CustomColorScheme colorScheme) {
    final minWidth = minWidthOfMessage(context);
    return Container(
      constraints: BoxConstraints.loose(Size.fromWidth(minWidth - 16)),
      height: 18,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _roomRepo.getName(widget.message.from.asUid()),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return showName(colorScheme, snapshot.data!);
                } else {
                  return const Text("");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showName(CustomColorScheme colorScheme, String name) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Text(
          name.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          _routingServices.openProfile(widget.message.from);
        },
      ),
    );
  }
}
