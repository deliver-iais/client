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
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hovering/hovering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rxdart/rxdart.dart';

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
    nameFuture = _roomRepo.getName(widget.room.uid);
    if (!widget.room.synced) {
      _fetchRoomLastMessage();
    }
    if (widget.room.uid.category == Categories.USER) {
      _lastActivityRepo.updateLastActivity(widget.room.uid);
    }
    futureRoomName = _roomRepo.getName(widget.room.uid);
    super.initState();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _showAvatarsSubscription?.cancel();
    super.dispose();
  }

  void _fetchRoomLastMessage() => _messageRepo.fetchRoomLastMessage(
        widget.room.uid.asString(),
        widget.room.lastMessageId,
        widget.room.firstMessageId,
      );

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(widget.room.uid.node);
    return buildLastMessageWidget();
  }

  Widget buildLastMessageWidget() {
    final theme = Theme.of(context);
    final chatItemHeight = theme.primaryTextTheme.displayLarge!.height! + 12;

    final isPinnedRoom = widget.room.pinned;

    final activeHoverColor = Color.lerp(
      theme.colorScheme.primaryContainer,
      theme.colorScheme.outlineVariant,
      0.2,
    );

    final pinnedColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.08);

    final pinnedHoverColor = Color.lerp(
      pinnedColor,
      theme.dividerColor,
      0.1,
    );

    final activeColor = Color.lerp(
      theme.colorScheme.primaryContainer,
      theme.colorScheme.outlineVariant,
      0.1,
    );

    final dividerColor = Color.lerp(
      theme.colorScheme.outlineVariant,
      theme.colorScheme.primaryContainer,
      0.3,
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
                ? activeColor
                : isPinnedRoom
                    ? pinnedColor
                    : Colors.transparent,
          ),
          height: chatItemHeight,
          child: FutureBuilder<String>(
            initialData: _roomRepo.fastForwardName(widget.room.uid),
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
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: widget.isInRoom ? 0 : CHAT_AVATAR_RADIUS * 2 + p8 * 2,
            ),
            child: Divider(
              height: 0.6,
              thickness: 0.6,
              color: dividerColor,
            ),
          )
        else
          Container(
            height: 1,
            width: double.infinity,
            color: pinnedColor,
            child: Divider(
              height: 0.6,
              thickness: 0.6,
              color: dividerColor,
            ),
          )
      ],
    );
  }

  Widget buildLastMessage(Message message) {
    return AsyncLastMessage(
      message: message,
      showSender: widget.room.uid.isGroup(),
    );
  }

  Widget buildChatItemWidget(String name) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        if (settings.showAvatars.value)
          ChatAvatar(
            widget.room.uid,
            borderColor:
                widget.isInRoom ? theme.colorScheme.primaryContainer : null,
          ),
        if (settings.showAvatars.value) const SizedBox(width: p8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  _buildChatIcon(
                    _getChatIconDataByUid(widget.room.uid),
                  ),
                  if (widget.room.uid.isMuc() || widget.room.uid.isBot())
                    const SizedBox(width: p4),
                  Expanded(
                    child: RoomName(
                      uid: widget.room.uid,
                      name: name,
                    ),
                  ),
                  if (widget.room.lastMessage != null)
                    ..._buildLastMessageTimeAndSeenStatus(
                      widget.room.lastMessage!,
                    ),
                ],
              ),
              const SizedBox(
                height: p8,
              ),
              Row(
                children: [
                  StreamBuilder<Activity>(
                    stream: _roomRepo.activityObject[widget.room.uid.node],
                    builder: (c, roomActivityStream) {
                      return Expanded(
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
                                  roomUid: widget.room.uid,
                                )
                              : FutureBuilder<Seen>(
                                  future: _roomRepo
                                      .getMySeen(widget.room.uid.asString()),
                                  key: ValueKey(
                                    "future-builder${widget.room.uid}-${widget.room.lastMessageId}",
                                  ),
                                  builder: (context, snapshot) {
                                    var unreadCount = 0;
                                    if (snapshot.hasData &&
                                        snapshot.data != null &&
                                        snapshot.data!.messageId > -1) {
                                      unreadCount = widget.room.lastMessageId -
                                          snapshot.data!.messageId;
                                      if (snapshot.data?.hiddenMessageCount !=
                                          null) {
                                        unreadCount = unreadCount -
                                            snapshot.data!.hiddenMessageCount;
                                      }
                                    }

                                    if (widget.room.draft.isNotEmpty &&
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
                      );
                    },
                  ),
                  if (widget.room.mentionsId.isNotEmpty)
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

  List<Widget> _buildLastMessageTimeAndSeenStatus(Message message) {
    return [
      if (_authRepo.isCurrentUser(message.from))
        Padding(
          padding: const EdgeInsets.all(p4),
          child: SeenStatus(
            message.roomUid,
            message.packetId,
            messageId: message.id,
          ),
        ),
      Text(
        dateTimeFromNowFormat(
          date(widget.room.lastMessage!.time),
          summery: true,
        ),
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 11,
        ),
        textDirection: _i18n.defaultTextDirection,
      ),
    ];
  }

  IconData? _getChatIconDataByUid(Uid uid) {
    switch (uid.category) {
      case Categories.BOT:
        return MdiIcons.robotOutline;
      case Categories.BROADCAST:
        return MdiIcons.broadcast;
      case Categories.CHANNEL:
        return Icons.campaign_outlined;
      case Categories.GROUP:
        return CupertinoIcons.person_2_fill;
      case Categories.STORE:
      case Categories.SYSTEM:
      case Categories.USER:
        return null;
    }
    return null;
  }

  Widget _buildChatIcon(IconData? iconData) {
    if (iconData != null) {
      return Icon(
        iconData,
        size: 16,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildDraftMessageWidget(I18N i18n, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        RichText(
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
      ],
    );
  }
}
