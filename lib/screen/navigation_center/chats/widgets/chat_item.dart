import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver/shared/widgets/drag_and_drop_widget.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:hovering/hovering.dart';

import 'contact_pic.dart';
import 'last_message.dart';

class ChatItem extends StatefulWidget {
  final Room room;

  const ChatItem({Key? key, required this.room}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    if (widget.room.uid.asUid().category == Categories.USER) {
      _lastActivityRepo.updateLastActivity(widget.room.uid.asUid());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(widget.room.uid.asUid().node);
    return widget.room.lastMessage != null &&
            widget.room.lastMessage!.json!.chatIsDeleted()
        ? const SizedBox.shrink()
        : widget.room.lastMessage == null ||
                widget.room.lastMessage!.json!.isDeletedMessage()
            ? FutureBuilder<Message?>(
                future: _messageRepo.fetchLastMessages(
                    widget.room.uid.asUid(),
                    widget.room.lastMessageId!,
                    widget.room.firstMessageId,
                    widget.room,
                    limit: 5,
                    type: FetchMessagesReq_Type.BACKWARD_FETCH),
                builder: (c, s) {
                  if (s.hasData &&
                      s.data != null &&
                      !s.data!.json!.chatIsDeleted()) {
                    return buildLastMessageWidget(s.data!);
                  }
                  return const SizedBox.shrink();
                })
            : buildLastMessageWidget(widget.room.lastMessage!);
  }

  buildLastMessageWidget(Message lastMessage) {
    final activeHoverColor = Color.lerp(
        Theme.of(context).focusColor, Theme.of(context).dividerColor, 0.1);
    final hoverColor = Theme.of(context).hoverColor;

    return FutureBuilder<String>(
        initialData: _roomRepo.fastForwardName(widget.room.uid.asUid()),
        future: _roomRepo.getName(widget.room.uid.asUid()),
        builder: (c, name) {
          if (name.hasData && name.data != null && name.data!.isNotEmpty) {
            return DragDropWidget(
                roomUid: widget.room.uid,
                height: 66,
                child: StreamBuilder<String>(
                    stream: _routingService.currentRouteStream,
                    builder: (context, snapshot) {
                      return HoverContainer(
                        cursor: SystemMouseCursors.click,
                        margin: const EdgeInsets.only(right: 12, left: 6),
                        padding: const EdgeInsets.all(8),
                        hoverDecoration: BoxDecoration(
                            color: _routingService.isInRoom(widget.room.uid)
                                ? activeHoverColor
                                : hoverColor,
                            borderRadius: secondaryBorder),
                        decoration: BoxDecoration(
                            color: _routingService.isInRoom(widget.room.uid)
                                ? Theme.of(context).focusColor
                                : Colors.transparent,
                            borderRadius: secondaryBorder),
                        height: 66,
                        child: Row(
                          children: <Widget>[
                            ContactPic(widget.room.uid.asUid()),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      if (widget.room.uid.asUid().category ==
                                          Categories.GROUP)
                                        const Flexible(
                                          child: Icon(
                                            Icons.group_outlined,
                                            size: 16,
                                          ),
                                        ),
                                      if (widget.room.uid.asUid().category ==
                                          Categories.CHANNEL)
                                        const Flexible(
                                          child: Icon(
                                            Icons.rss_feed_outlined,
                                            size: 15,
                                          ),
                                        ),
                                      if (widget.room.uid.asUid().category ==
                                          Categories.BOT)
                                        const Flexible(
                                          child: Icon(
                                            Icons.smart_toy_outlined,
                                            size: 16,
                                          ),
                                        ),
                                      Expanded(
                                          flex: 80,
                                          child: Padding(
                                              padding: widget.room.uid
                                                          .asUid()
                                                          .isGroup() ||
                                                      widget.room.uid
                                                          .asUid()
                                                          .isChannel() ||
                                                      widget.room.uid
                                                          .asUid()
                                                          .isBot()
                                                  ? const EdgeInsets.only(
                                                      left: 16.0)
                                                  : EdgeInsets.zero,
                                              child: RoomName(
                                                  uid: widget.room.uid.asUid(),
                                                  name: _authRepo.isCurrentUser(
                                                          widget.room.uid)
                                                      ? _i18n
                                                          .get("saved_message")
                                                      : name.data!))),
                                      Text(
                                        dateTimeFormat(
                                            date(widget.room.lastUpdateTime!)),
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w100,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  StreamBuilder<Activity>(
                                      stream: _roomRepo.activityObject[
                                          widget.room.uid.asUid().node],
                                      builder: (c, s) {
                                        if (s.hasData &&
                                            s.data != null &&
                                            s.data!.typeOfActivity !=
                                                ActivityType.NO_ACTIVITY) {
                                          return Row(
                                            children: [
                                              ActivityStatus(
                                                activity: s.data!,
                                                roomUid:
                                                    widget.room.uid.asUid(),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return widget.room.draft != null &&
                                                  widget.room.draft!.isNotEmpty
                                              ? buildDraftMessageWidget(
                                                  _i18n, context)
                                              : buildLastMessage(lastMessage);
                                        }
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }));
          } else {
            return defaultChatItem();
          }
        });
  }

  Padding defaultChatItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 11.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[300]
                    : Colors.grey[800],
                shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 16,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[300]
                    : Colors.grey[800],
              ),
              const SizedBox(height: 10),
              Container(
                width: 200,
                height: 13,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[300]
                    : Colors.grey[800],
              ),
            ],
          ),
        ],
      ),
    );
  }

  LastMessage buildLastMessage(Message message) {
    return LastMessage(
      message: message,
      lastMessageId: widget.room.lastMessageId!,
      hasMentioned: widget.room.mentioned == true,
      showSender:
          widget.room.uid.isMuc() || _authRepo.isCurrentUser(message.from),
      pinned: widget.room.pinned ?? false,
    );
  }

  Widget buildDraftMessageWidget(I18N _i18n, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              textDirection: TextDirection.ltr,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "${_i18n.get("draft")}: ",
                      style: Theme.of(context).primaryTextTheme.bodyText2),
                  TextSpan(
                      text: widget.room.draft,
                      style: Theme.of(context).textTheme.bodyText2)
                ],
              )),
        ),
      ],
    );
  }
}
