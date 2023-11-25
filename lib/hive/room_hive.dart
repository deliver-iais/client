import 'package:collection/collection.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'room_hive.g.dart';

@HiveType(typeId: ROOM_METADATA_TRACK_ID)
class RoomHive {
  // Table ID
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  String? lastMessage;

  @HiveField(2)
  bool deleted;

  @HiveField(4)
  int lastMessageId;

  @HiveField(5)
  String? draft;

  @HiveField(6)
  int lastUpdateTime;

  @HiveField(7)
  int firstMessageId;

  @HiveField(8)
  bool pinned;

  @HiveField(9)
  int pinId;

  @HiveField(10)
  bool synced;

  @HiveField(11)
  int lastCurrentUserSentMessageId;

  @HiveField(12)
  bool seenSynced;

  @HiveField(13)
  String? replyKeyboardMarkup;

  @HiveField(14)
  List<int>? mentionsId;

  @HiveField(15)
  bool shouldUpdateMediaCount;

  @HiveField(16)
  int localNetworkMessageCount;

  @HiveField(17)
  int lastLocalNetworkMessageId;

  RoomHive({
    required this.uid,
    this.lastMessage,
    this.draft,
    this.lastUpdateTime = 0,
    this.lastMessageId = 0,
    this.localNetworkMessageCount = 0,
    this.lastLocalNetworkMessageId = 0,
    this.firstMessageId = 0,
    this.deleted = false,
    this.pinned = false,
    this.pinId = 0,
    this.synced = false,
    this.lastCurrentUserSentMessageId = 0,
    this.seenSynced = false,
    this.replyKeyboardMarkup,
    this.mentionsId,
    this.shouldUpdateMediaCount = true,
  });

  RoomHive copyWith({
    String? uid,
    String? lastMessage,
    int? lastMessageId,
    bool? deleted,
    String? draft,
    int? lastUpdateTime,
    int? firstMessageId,
    bool? mentioned,
    bool? pinned,
    int? pinId,
    bool? synced,
    int? localNetworkMessageCount,
    int? lastLocalNetworkMessageId,
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    String? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
    List<int>? mentionsId,
    bool? shouldUpdateMediaCount,
  }) =>
      RoomHive(
        uid: uid ?? this.uid,
        lastMessage: lastMessage ?? this.lastMessage,
        deleted: deleted ?? this.deleted,
        draft: draft ?? this.draft,
        localNetworkMessageCount:
            localNetworkMessageCount ?? this.localNetworkMessageCount,
        lastLocalNetworkMessageId:
            lastLocalNetworkMessageId ?? this.lastLocalNetworkMessageId,
        lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
        firstMessageId: firstMessageId ?? this.firstMessageId,
        lastMessageId: lastMessageId ?? this.lastMessageId,
        pinned: pinned ?? this.pinned,
        pinId: pinId ?? this.pinId,
        synced: synced ?? this.synced,
        lastCurrentUserSentMessageId:
            lastCurrentUserSentMessageId ?? this.lastCurrentUserSentMessageId,
        seenSynced: seenSynced ?? this.seenSynced,
        replyKeyboardMarkup: replyKeyboardMarkup ??
            (forceToUpdateReplyKeyboardMarkup
                ? null
                : this.replyKeyboardMarkup),
        mentionsId: mentionsId ?? this.mentionsId,
        shouldUpdateMediaCount:
            shouldUpdateMediaCount ?? this.shouldUpdateMediaCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is RoomHive &&
          const DeepCollectionEquality().equals(other.uid, uid) &&
          const DeepCollectionEquality()
              .equals(other.lastMessage, lastMessage) &&
          const DeepCollectionEquality().equals(other.deleted, deleted) &&
          const DeepCollectionEquality().equals(other.draft, draft) &&
          const DeepCollectionEquality()
              .equals(other.lastUpdateTime, lastUpdateTime) &&
          const DeepCollectionEquality()
              .equals(other.firstMessageId, firstMessageId) &&
          const DeepCollectionEquality()
              .equals(other.lastMessageId, lastMessageId) &&
          const DeepCollectionEquality().equals(other.pinned, pinned) &&
          const DeepCollectionEquality().equals(other.pinId, pinId) &&
          const DeepCollectionEquality().equals(
            other.lastCurrentUserSentMessageId,
            lastCurrentUserSentMessageId,
          ) &&
          const DeepCollectionEquality().equals(other.synced, synced) &&
          const DeepCollectionEquality().equals(
              other.localNetworkMessageCount, localNetworkMessageCount) &&
          const DeepCollectionEquality().equals(other.seenSynced, seenSynced) &&
          const DeepCollectionEquality()
              .equals(other.replyKeyboardMarkup, replyKeyboardMarkup) &&
          const DeepCollectionEquality()
              .equals(other.shouldUpdateMediaCount, shouldUpdateMediaCount) &&
          const DeepCollectionEquality().equals(other.mentionsId, mentionsId));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(uid),
        const DeepCollectionEquality().hash(lastMessage),
        const DeepCollectionEquality().hash(deleted),
        const DeepCollectionEquality().hash(draft),
        const DeepCollectionEquality().hash(lastUpdateTime),
        const DeepCollectionEquality().hash(firstMessageId),
        const DeepCollectionEquality().hash(lastMessageId),
        const DeepCollectionEquality().hash(pinned),
        const DeepCollectionEquality().hash(pinId),
        const DeepCollectionEquality().hash(synced),
        const DeepCollectionEquality().hash(lastCurrentUserSentMessageId),
        const DeepCollectionEquality().hash(seenSynced),
        const DeepCollectionEquality().hash(shouldUpdateMediaCount),
        const DeepCollectionEquality().hash(replyKeyboardMarkup),
        const DeepCollectionEquality().hash(mentionsId),
        const DeepCollectionEquality().hash(localNetworkMessageCount),
        const DeepCollectionEquality().hash(lastLocalNetworkMessageId),
      );

  @override
  String toString() {
    return "Room [uid:$uid] [deleted:$deleted] [draft:$draft] [lastUpdateTime:$lastUpdateTime] [firstMessageId:$firstMessageId] [lastMessageId:$lastMessageId] [pinned:$pinned] [lastMessage:$lastMessage] [pinId:$pinId] [synced:$synced] [lastCurrentUserSentMessageId:$lastCurrentUserSentMessageId] [seenSynced:$seenSynced] [mentionsId:$mentionsId] [lastLocalNetworkMessageId:$localNetworkMessageCount]";
  }

  Room fromHive() => Room(
        uid: uid.asUid(),
        lastMessage: getNullableMessageFromJson(lastMessage),
        lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
        synced: synced,
        seenSynced: seenSynced,
        shouldUpdateMediaCount: shouldUpdateMediaCount,
        deleted: deleted,
        draft: draft ?? '',
        replyKeyboardMarkup: replyKeyboardMarkup,
        mentionsId: mentionsId ?? [],
        lastUpdateTime: lastUpdateTime,
        pinId: pinId,
        pinned: pinned,
        localNetworkMessageCount: localNetworkMessageCount,
        lastLocalNetworkMessageId: lastLocalNetworkMessageId,
        firstMessageId: firstMessageId,
        lastMessageId: lastMessageId,
      );
}

extension RoomHiveMapper on Room {
  RoomHive toHive() => RoomHive(
        uid: uid.asString(),
        lastMessage: nullableMessageToJson(lastMessage),
        lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
        synced: synced,
        seenSynced: seenSynced,
        shouldUpdateMediaCount: shouldUpdateMediaCount,
        deleted: deleted,
        draft: draft,
        replyKeyboardMarkup: replyKeyboardMarkup,
        mentionsId: mentionsId,
        lastLocalNetworkMessageId: lastLocalNetworkMessageId,
        lastUpdateTime: lastUpdateTime,
        pinId: pinId,
        localNetworkMessageCount: localNetworkMessageCount,
        pinned: pinned,
        firstMessageId: firstMessageId,
        lastMessageId: lastMessageId,
      );
}
