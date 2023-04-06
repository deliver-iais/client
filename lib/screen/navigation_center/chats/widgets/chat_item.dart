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
import 'package:deliver/screen/navigation_center/chats/widgets/chat_avatar.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
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
import 'package:rxdart/rxdart.dart';

import 'last_message.dart';

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

  late final Future<String> nameFuture;

  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<bool>? _showAvatarsSubscription;
  late final Future<String> futureRoomName;

  @override
  void didUpdateWidget(ChatItem oldWidget) {
    if (!widget.room.synced) {
      _fetchRoomLastMessage();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _showAvatarsSubscription = MergeStream([
      settings.showAvatars.stream,
      settings.showAvatarImages.stream,
    ]).listen((_) => setState(() {}));
    nameFuture = _roomRepo.getName(widget.room.uid.asUid());
    if (!widget.room.synced) {
      _fetchRoomLastMessage();
    }
    if (widget.room.uid.asUid().category == Categories.USER) {
      _lastActivityRepo.updateLastActivity(widget.room.uid.asUid());
    }
    futureRoomName = _roomRepo.getName(widget.room.uid.asUid());
    super.initState();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _showAvatarsSubscription?.cancel();
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
    final chatItemHeight = theme.primaryTextTheme.displayLarge!.height! + 12;

    final isPinnedRoom = widget.room.pinned;

    final activeHoverColor =
        Color.lerp(theme.colorScheme.primaryContainer, theme.dividerColor, 0.1);

    final pinnedColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.08);

    final pinnedHoverColor = Color.lerp(
      pinnedColor,
      theme.dividerColor,
      0.1,
    );

    final hoverColor = theme.hoverColor;
    return Column(
      children: [
        HoverContainer(
          cursor: SystemMouseCursors.click,
          padding: const EdgeInsetsDirectional.only(start: p8, end: p12),
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
            future: futureRoomName,
            builder: (c, nameSnapshot) {
              final name = _authRepo.isCurrentUser(widget.room.uid)
                  ? _i18n.get("saved_message")
                  : nameSnapshot.data ?? "";
              return buildChatItemWidget(name);
            },
          ),
        ),
        if (!isPinnedRoom)
          const Divider(height: 0.7, thickness: 0.7)
        else
          Container(
            height: 1,
            width: double.infinity,
            color: pinnedColor,
            child: const Divider(height: 0.7, thickness: 0.7),
          )
      ],
    );
  }

  Widget buildLastMessage(Message message) {
    return AsyncLastMessage(
      message: message,
      showSeenStatus: _authRepo.isCurrentUser(message.from),
      showSender:
          widget.room.uid.isGroup() || _authRepo.isCurrentUser(message.from),
    );
  }

  Widget buildChatItemWidget(String name) {
    final theme = Theme.of(context);
    final detailsHeight = (theme.primaryTextTheme.bodyLarge!.fontSize! + 3) * 2;

    return Row(
      children: <Widget>[
        if (settings.showAvatars.value) ChatAvatar(widget.room.uid.asUid()),
        if (settings.showAvatars.value) const SizedBox(width: p8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  if (widget.room.uid.asUid().category == Categories.GROUP)
                    const Icon(
                      CupertinoIcons.person_2_fill,
                      size: 16,
                    ),
                  if (widget.room.uid.asUid().category == Categories.CHANNEL)
                    const Icon(
                      CupertinoIcons.news_solid,
                      size: 16,
                    ),
                  if (widget.room.uid.asUid().category == Categories.BOT)
                    const Icon(
                      Icons.smart_toy,
                      size: 16,
                    ),
                  if (widget.room.uid.asUid().isGroup() ||
                      widget.room.uid.asUid().isChannel() ||
                      widget.room.uid.asUid().isBot())
                    const SizedBox(width: p4),
                  Expanded(
                    child: RoomName(
                      uid: widget.room.uid.asUid(),
                      name: name,
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
              const SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  StreamBuilder<Activity>(
                    stream:
                        _roomRepo.activityObject[widget.room.uid.asUid().node],
                    builder: (c, roomActivityStream) {
                      return Expanded(
                        child: SizedBox(
                          height: detailsHeight,
                          child: AnimatedSwitcher(
                            duration: AnimationSettings.slow,
                            child: (roomActivityStream.hasData &&
                                    roomActivityStream.data != null &&
                                    roomActivityStream.data!.typeOfActivity !=
                                        ActivityType.NO_ACTIVITY)
                                ? ActivityStatus(
                                    key: ValueKey(
                                      "activity-status${widget.room.uid}",
                                    ),
                                    activity: roomActivityStream.data!,
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

                                      if (widget.room.draft != null &&
                                          widget.room.draft!.isNotEmpty &&
                                          unreadCount == 0) {
                                        return buildDraftMessageWidget(
                                          _i18n,
                                          context,
                                        );
                                      } else if (widget.room.lastMessage !=
                                          null) {
                                        return buildLastMessage(
                                          widget.room.lastMessage!,
                                        );
                                      } else {
                                        return const SizedBox(
                                          height: 3,
                                          width: 5,
                                        );
                                      }
                                    },
                                  ),
                          ),
                        ),
                      );
                    },
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
                      !_authRepo.isCurrentUser(widget.room.lastMessage!.from))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: p4),
                      child: UnreadMessageCounterWidget(
                        widget.room.lastMessage!.roomUid,
                        widget.room.lastMessageId,
                        key: ValueKey(
                          "unread-count${widget.room.uid}",
                        ),
                      ),
                    ),
                  if (widget.room.pinned)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: p4),
                      child: Icon(
                        CupertinoIcons.pin,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                ],
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
                  style: theme.primaryTextTheme.bodyMedium,
                ),
                TextSpan(
                  text: widget.room.draft,
                  style: theme.textTheme.bodyMedium,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
