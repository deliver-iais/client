import 'package:collection/collection.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: ROOM_METADATA_TRACK_ID)
class Room {
  // Table ID
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  Message? lastMessage;

  @HiveField(2)
  bool? deleted;

  @HiveField(3)
  bool? mentioned;

  @HiveField(4)
  int? lastMessageId;

  @HiveField(5)
  String? draft;

  @HiveField(6)
  int? lastUpdateTime;

  @HiveField(7)
  int? firstMessageId;

  @HiveField(8)
  bool? pinned;

  @HiveField(9)
  int? lastUpdatedMessageId;

  Room(
      {required this.uid,
      this.lastMessage,
      this.deleted,
      this.mentioned,
      this.draft,
      this.lastUpdateTime,
      this.lastMessageId,
      this.firstMessageId,
      this.pinned,
      this.lastUpdatedMessageId});

  Room copy(Room r) => Room(
      uid: r.uid,
      lastMessage: r.lastMessage ?? lastMessage,
      deleted: r.deleted ?? deleted,
      draft: r.draft ?? draft,
      lastUpdateTime: r.lastUpdateTime ?? lastUpdateTime,
      mentioned: r.mentioned ?? mentioned,
      lastMessageId: r.lastMessageId ?? lastMessageId,
      firstMessageId: r.firstMessageId ?? firstMessageId,
      pinned: r.pinned ?? pinned,
      lastUpdatedMessageId: r.lastUpdatedMessageId ?? lastUpdatedMessageId);

  Room copyWith(
          {String? uid,
          Message? lastMessage,
          int? lastMessageId,
          bool? deleted,
          String? draft,
          int? lastUpdateTime,
          int? firstMessageId,
          int? lastUpdatedMessageId,
          bool? mentioned,
          bool? pinned,
          int? hiddenMessageCount}) =>
      Room(
          uid: uid ?? this.uid,
          lastMessage: lastMessage ?? this.lastMessage,
          deleted: deleted ?? this.deleted,
          draft: draft ?? this.draft,
          lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
          mentioned: mentioned ?? this.mentioned,
          firstMessageId: firstMessageId ?? this.firstMessageId,
          lastMessageId: lastMessageId ?? this.lastMessageId,
          pinned: pinned ?? this.pinned,
          lastUpdatedMessageId:
              lastUpdatedMessageId ?? this.lastUpdatedMessageId);

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Room &&
            const DeepCollectionEquality().equals(other.uid, uid) &&
            const DeepCollectionEquality()
                .equals(other.lastMessage, lastMessage) &&
            const DeepCollectionEquality().equals(other.deleted, deleted) &&
            const DeepCollectionEquality().equals(other.draft, draft) &&
            const DeepCollectionEquality()
                .equals(other.lastUpdateTime, lastUpdateTime) &&
            const DeepCollectionEquality().equals(other.mentioned, mentioned) &&
            const DeepCollectionEquality()
                .equals(other.firstMessageId, firstMessageId) &&
            const DeepCollectionEquality()
                .equals(other.lastMessageId, lastMessageId) &&
            const DeepCollectionEquality().equals(other.pinned, pinned) &&
            const DeepCollectionEquality()
                .equals(other.lastUpdatedMessageId, lastUpdatedMessageId));
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(uid),
        const DeepCollectionEquality().hash(lastMessage),
        const DeepCollectionEquality().hash(deleted),
        const DeepCollectionEquality().hash(draft),
        const DeepCollectionEquality().hash(lastUpdateTime),
        const DeepCollectionEquality().hash(mentioned),
        const DeepCollectionEquality().hash(firstMessageId),
        const DeepCollectionEquality().hash(lastMessageId),
        const DeepCollectionEquality().hash(pinned),
        const DeepCollectionEquality().hash(lastUpdatedMessageId),
      );
}
