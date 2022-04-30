import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

    if (widget.room.lastMessage == null) return const SizedBox.shrink();

    return buildLastMessageWidget(widget.room.lastMessage!);
  }

  Widget buildLastMessageWidget(Message lastMessage) {
    final theme = Theme.of(context);
    final activeHoverColor =
        Color.lerp(theme.focusColor, theme.dividerColor, 0.1);
    final hoverColor = theme.hoverColor;

    return FutureBuilder<String>(
      initialData: _roomRepo.fastForwardName(widget.room.uid.asUid()),
      future: _roomRepo.getName(widget.room.uid.asUid()),
      builder: (c, name) {
        if (name.hasData && name.data!.isNotEmpty ||
            _authRepo.isCurrentUser(widget.room.uid)) {
          return DragDropWidget(
            roomUid: widget.room.uid,
            height: 66,
            child: StreamBuilder<String>(
              stream: _routingService.currentRouteStream,
              builder: (context, snapshot) {
                return HoverContainer(
                  cursor: SystemMouseCursors.click,
                  margin: const EdgeInsets.only(right: 6, left: 6),
                  padding: const EdgeInsets.all(8),
                  hoverDecoration: BoxDecoration(
                    color: _routingService.isInRoom(widget.room.uid)
                        ? activeHoverColor
                        : hoverColor,
                    borderRadius: secondaryBorder,
                  ),
                  decoration: BoxDecoration(
                    color: _routingService.isInRoom(widget.room.uid)
                        ? theme.focusColor
                        : Colors.transparent,
                    borderRadius: secondaryBorder,
                  ),
                  height: 66,
                  child: Row(
                    children: <Widget>[
                      ContactPic(widget.room.uid.asUid()),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Row(
                              children: [
                                if (widget.room.uid.asUid().category ==
                                    Categories.GROUP)
                                  const SizedBox(
                                    width: 16,
                                    child: Icon(
                                      CupertinoIcons.person_2_fill,
                                      size: 16,
                                    ),
                                  ),
                                if (widget.room.uid.asUid().category ==
                                    Categories.CHANNEL)
                                  const SizedBox(
                                    width: 16,
                                    child: Icon(
                                      CupertinoIcons.news_solid,
                                      size: 16,
                                    ),
                                  ),
                                if (widget.room.uid.asUid().category ==
                                    Categories.BOT)
                                  const SizedBox(
                                    width: 16,
                                    child: Icon(
                                      CupertinoIcons.bolt_horizontal_circle,
                                      size: 16,
                                    ),
                                  ),
                                Expanded(
                                  flex: 80,
                                  child: Padding(
                                    padding:
                                        widget.room.uid.asUid().isGroup() ||
                                                widget.room.uid
                                                    .asUid()
                                                    .isChannel() ||
                                                widget.room.uid.asUid().isBot()
                                            ? const EdgeInsets.only(
                                                left: 4.0,
                                              )
                                            : EdgeInsets.zero,
                                    child: RoomName(
                                      uid: widget.room.uid.asUid(),
                                      name: _authRepo.isCurrentUser(
                                        widget.room.uid,
                                      )
                                          ? _i18n.get("saved_message")
                                          : name.data!,
                                    ),
                                  ),
                                ),
                                if (widget.room.lastMessage != null)
                                  Text(
                                    dateTimeFromNowFormat(
                                      date(widget.room.lastMessage!.time),
                                    ),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            StreamBuilder<Activity>(
                              stream: _roomRepo
                                  .activityObject[widget.room.uid.asUid().node],
                              builder: (c, s) {
                                if (s.hasData &&
                                    s.data != null &&
                                    s.data!.typeOfActivity !=
                                        ActivityType.NO_ACTIVITY) {
                                  return Row(
                                    children: [
                                      ActivityStatus(
                                        activity: s.data!,
                                        roomUid: widget.room.uid.asUid(),
                                      ),
                                    ],
                                  );
                                } else {
                                  return widget.room.draft != null &&
                                          widget.room.draft!.isNotEmpty
                                      ? buildDraftMessageWidget(
                                          _i18n,
                                          context,
                                        )
                                      : buildLastMessage(lastMessage);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return defaultChatItem();
        }
      },
    );
  }

  Padding defaultChatItem() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.grey[300]
                  : Colors.grey[800],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 15,
                    color: theme.brightness == Brightness.light
                        ? Colors.grey[300]
                        : Colors.grey[800],
                  ),
                  Container(
                    width: 35,
                    height: 15,
                    color: theme.brightness == Brightness.light
                        ? Colors.grey[300]
                        : Colors.grey[800],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: 212,
                height: 12,
                color: theme.brightness == Brightness.light
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
      lastMessageId: widget.room.lastMessageId,
      hasMentioned: widget.room.mentioned == true,
      showSender:
          widget.room.uid.isMuc() || _authRepo.isCurrentUser(message.from),
      pinned: widget.room.pinned,
    );
  }

  Widget buildDraftMessageWidget(I18N _i18n, BuildContext context) {
    final theme = Theme.of(context);
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
                  style: theme.primaryTextTheme.bodyText2,
                ),
                TextSpan(
                  text: widget.room.draft,
                  style: theme.textTheme.bodyText2,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
