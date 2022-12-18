import 'dart:async';

import 'package:collection/collection.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hovering/hovering.dart';

import 'contact_pic.dart';
import 'last_message.dart';

const chatItemHeight = 78.0;

class RoomWrapper {
  final Room room;
  final bool isInRoom;

  const RoomWrapper({required this.room, required this.isInRoom});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is RoomWrapper &&
          const DeepCollectionEquality().equals(other.room, room) &&
          const DeepCollectionEquality().equals(other.isInRoom, isInRoom));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(room),
        const DeepCollectionEquality().hash(isInRoom),
      );
}

class ChatItem extends StatefulWidget {
  final Room room;
  final bool isInRoom;

  ChatItem({super.key, required RoomWrapper roomWrapper})
      : room = roomWrapper.room,
        isInRoom = roomWrapper.isInRoom;

  @override
  ChatItemState createState() => ChatItemState();
}

class ChatItemState extends State<ChatItem> {
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();

  StreamSubscription<Room>? _roomSubscription;

  @override
  void didUpdateWidget(ChatItem oldWidget) {
    if (!widget.room.synced) {
      _fetchRoomLastMessage();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    if (!widget.room.synced) {
      _fetchRoomLastMessage();
    }
    if (widget.room.uid.asUid().category == Categories.USER) {
      _lastActivityRepo.updateLastActivity(widget.room.uid.asUid());
    }
    super.initState();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  void _fetchRoomLastMessage() => _messageRepo.fetchRoomLastMessage(
        widget.room.uid,
        widget.room.lastMessageId,
        widget.room.firstMessageId,
      );

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(widget.room.uid.asUid().node);
    return buildLastMessageWidget();
  }

  Widget buildLastMessageWidget() {
    final theme = Theme.of(context);

    final isPinnedRoom = widget.room.pinned;

    final activeHoverColor =
        Color.lerp(theme.colorScheme.primaryContainer, theme.dividerColor, 0.1);

    final pinnedColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.08);

    final pinnedHoverColor = Color.lerp(
      pinnedColor,
      theme.dividerColor,
      0.5,
    );

    final hoverColor = theme.hoverColor;

    return Column(
      children: [
        HoverContainer(
          cursor: SystemMouseCursors.click,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hoverDecoration: BoxDecoration(
            color: widget.isInRoom
                ? activeHoverColor
                : isPinnedRoom
                    ? pinnedHoverColor
                    : hoverColor,
          ),
          decoration: BoxDecoration(
            color: widget.isInRoom
                ? theme.colorScheme.primaryContainer
                : isPinnedRoom
                    ? pinnedColor
                    : Colors.transparent,
          ),
          height: chatItemHeight,
          child: FutureBuilder<String>(
            initialData: _roomRepo.fastForwardName(widget.room.uid.asUid()),
            future: _roomRepo.getName(widget.room.uid.asUid()),
            builder: (c, nameSnapshot) {
              final name = _authRepo.isCurrentUser(widget.room.uid)
                  ? _i18n.get("saved_message")
                  : nameSnapshot.data ?? "";

              return buildChatItemWidget(name);
            },
          ),
        ),
        if (!isPinnedRoom)
          Padding(
            padding: const EdgeInsets.only(left: 76.0),
            child: widget.isInRoom
                ? const SizedBox(height: 0.5)
                : const Divider(height: 0.5, thickness: 0.5),
          )
        else
          Container(
            height: 1,
            width: double.infinity,
            color: pinnedColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 76.0),
              child: widget.isInRoom
                  ? const SizedBox(height: 0.5)
                  : const Divider(height: 0.5, thickness: 0.5),
            ),
          )
      ],
    );
  }

  Widget buildLastMessage(Message message) {
    return AsyncLastMessage(
      message: message,
      showSeenStatus: _authRepo.isCurrentUser(message.from),
      showSender:
          widget.room.uid.isMuc() || _authRepo.isCurrentUser(message.from),
    );
  }

  Widget buildChatItemWidget(String name) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        ContactPic(widget.room.uid.asUid()),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  if (widget.room.uid.asUid().category == Categories.GROUP)
                    const SizedBox(
                      width: 16,
                      child: Icon(
                        CupertinoIcons.person_2_fill,
                        size: 16,
                      ),
                    ),
                  if (widget.room.uid.asUid().category == Categories.CHANNEL)
                    const SizedBox(
                      width: 16,
                      child: Icon(
                        CupertinoIcons.news_solid,
                        size: 16,
                      ),
                    ),
                  if (widget.room.uid.asUid().category == Categories.BOT)
                    const SizedBox(
                      width: 16,
                      child: Icon(
                        Icons.smart_toy,
                        size: 16,
                      ),
                    ),
                  Expanded(
                    flex: 80,
                    child: Padding(
                      padding: widget.room.uid.asUid().isGroup() ||
                              widget.room.uid.asUid().isChannel() ||
                              widget.room.uid.asUid().isBot()
                          ? const EdgeInsets.only(
                              left: 4.0,
                            )
                          : EdgeInsets.zero,
                      child: RoomName(
                        uid: widget.room.uid.asUid(),
                        name: name,
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
                      textDirection: _i18n.defaultTextDirection,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              StreamBuilder<Activity>(
                stream: _roomRepo.activityObject[widget.room.uid.asUid().node],
                builder: (c, s) {
                  {
                    return Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: SLOW_ANIMATION_DURATION,
                            child: (s.hasData &&
                                    s.data != null &&
                                    s.data!.typeOfActivity !=
                                        ActivityType.NO_ACTIVITY)
                                ? ActivityStatus(
                                    key: ValueKey(
                                      "activity-status${widget.room.uid}",
                                    ),
                                    activity: s.data!,
                                    roomUid: widget.room.uid.asUid(),
                                  )
                                : FutureBuilder<Seen>(
                                    future:
                                        _roomRepo.getMySeen(widget.room.uid),
                                    key: ValueKey(
                                      "future-builder${widget.room.uid}-${widget.room.lastMessageId}",
                                    ),
                                    builder: (context, snapshot) {
                                      var unreadCount = 0;
                                      if (snapshot.hasData &&
                                          snapshot.data != null &&
                                          snapshot.data!.messageId > -1) {
                                        unreadCount =
                                            widget.room.lastMessageId -
                                                snapshot.data!.messageId;
                                        if (snapshot.data?.hiddenMessageCount !=
                                            null) {
                                          unreadCount = unreadCount -
                                              snapshot.data!.hiddenMessageCount;
                                        }
                                      }
                                      return widget.room.draft != null &&
                                              widget.room.draft!.isNotEmpty &&
                                              unreadCount == 0
                                          ? buildDraftMessageWidget(
                                              _i18n,
                                              context,
                                            )
                                          : widget.room.lastMessage != null
                                              ? buildLastMessage(
                                                  widget.room.lastMessage!,
                                                )
                                              : const SizedBox(
                                                  height: 3,
                                                  width: 5,
                                                );
                                    },
                                  ),
                          ),
                        ),
                        if (widget.room.mentionsId != null &&
                            widget.room.mentionsId!.isNotEmpty)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.at,
                              size: 12,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        if (widget.room.lastMessage != null &&
                            !_authRepo
                                .isCurrentUser(widget.room.lastMessage!.from))
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: UnreadMessageCounterWidget(
                              widget.room.lastMessage!.roomUid,
                              widget.room.lastMessageId,
                            ),
                          ),
                        if (widget.room.pinned)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              CupertinoIcons.pin,
                              size: 16,
                              color: theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDraftMessageWidget(I18N i18n, BuildContext context) {
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
                  text: "${i18n.get("draft")}: ",
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
