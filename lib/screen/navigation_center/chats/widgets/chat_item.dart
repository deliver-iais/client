import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver/shared/widgets/drag_and_drop_widget.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hovering/hovering.dart';

import 'contact_pic.dart';
import 'last_message.dart';

class ChatItem extends StatefulWidget {
  final String roomUid;
  final Room initialRoomObject;

  const ChatItem(
      {Key? key, required this.roomUid, required this.initialRoomObject})
      : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    print("reinit");
    super.initState();
    if (widget.roomUid.asUid().category == Categories.USER) {
      _lastActivityRepo.updateLastActivity(widget.roomUid.asUid());
    }
    // fetchMessages();
    _roomRepo.initActivity(widget.roomUid.asUid().node);
  }

  void fetchMessages() {
    // _messageRepo.fetchLastMessages(
    //     widget.roomUid.asUid(),
    //     widget.room.lastMessageId!,
    //     widget.room.firstMessageId,
    //     widget.room,
    //     limit: 5,
    //     type: FetchMessagesReq_Type.BACKWARD_FETCH);
  }

  @override
  Widget build(BuildContext context) {
    print("repaint");
    return StreamBuilder<Room?>(
        initialData: widget.initialRoomObject,
        // key: widget.key,
        stream: _roomRepo.watchRoom(widget.roomUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.lastMessage == null) {
            return const SizedBox.shrink();
          }
          return buildLastMessageWidget(snapshot.data!);
        });
  }

  buildLastMessageWidget(Room room) {
    return FutureBuilder<String>(
        initialData: _roomRepo.fastForwardName(widget.roomUid.asUid()),
        future: _roomRepo.getName(widget.roomUid.asUid()),
        builder: (c, name) {
          if (name.hasData && name.data != null && name.data!.isNotEmpty) {
            return DragDropWidget(
                roomUid: widget.roomUid,
                height: 66,
                child: HoverContainer(
                  hoverColor: Theme.of(context).dividerColor,
                  cursor: SystemMouseCursors.click,
                  color: Colors.transparent,
                  child: StreamBuilder<String>(
                      stream: _routingService.currentRouteStream,
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          color: _routingService.isInRoom(widget.roomUid)
                              ? Theme.of(context).focusColor
                              : Colors.transparent,
                          height: 66,
                          child: Row(
                            children: <Widget>[
                              ContactPic(widget.roomUid.asUid()),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        if (widget.roomUid.asUid().category ==
                                            Categories.GROUP)
                                          const Flexible(
                                            child: Icon(
                                              Icons.group_outlined,
                                              size: 16,
                                            ),
                                          ),
                                        if (widget.roomUid.asUid().category ==
                                            Categories.CHANNEL)
                                          const Flexible(
                                            child: Icon(
                                              Icons.rss_feed_outlined,
                                              size: 15,
                                            ),
                                          ),
                                        if (widget.roomUid.asUid().category ==
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
                                                padding: widget.roomUid
                                                            .asUid()
                                                            .isGroup() ||
                                                        widget.roomUid
                                                            .asUid()
                                                            .isChannel() ||
                                                        widget.roomUid
                                                            .asUid()
                                                            .isBot()
                                                    ? const EdgeInsets.only(
                                                        left: 16.0)
                                                    : EdgeInsets.zero,
                                                child: RoomName(
                                                    uid: widget.roomUid.asUid(),
                                                    name:
                                                        _authRepo.isCurrentUser(
                                                                widget.roomUid)
                                                            ? _i18n.get(
                                                                "saved_message")
                                                            : name.data!))),
                                        Text(
                                          dateTimeFormat(
                                              date(room.lastUpdateTime!)),
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
                                            widget.roomUid.asUid().node],
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
                                                      widget.roomUid.asUid(),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return room.draft != null &&
                                                    room.draft!.isNotEmpty
                                                ? buildDraftMessageWidget(
                                                    room, context)
                                                : buildLastMessage(room);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ));
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

  LastMessage buildLastMessage(Room room) {
    final message = room.lastMessage!;

    return LastMessage(
      message: message,
      lastMessageId: room.lastMessageId!,
      hasMentioned: room.mentioned == true,
      showSender:
          widget.roomUid.isMuc() || _authRepo.isCurrentUser(message.from),
      pinned: room.pinned ?? false,
    );
  }

  Widget buildDraftMessageWidget(Room room, BuildContext context) {
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
                      text: room.draft,
                      style: Theme.of(context).textTheme.bodyText2)
                ],
              )),
        ),
      ],
    );
  }
}
