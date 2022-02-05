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
  int firstMessageId;

  @HiveField(8)
  bool pinned;

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
      this.firstMessageId = 0,
      this.pinned = false,
      this.lastUpdatedMessageId});

  Room copy(Room r) => Room(
      uid: r.uid,
      lastMessage: r.lastMessage ?? lastMessage,
      deleted: r.deleted ?? deleted,
      draft: r.draft ?? draft,
      lastUpdateTime: r.lastUpdateTime ?? lastUpdateTime,
      mentioned: r.mentioned ?? mentioned,
      lastMessageId: r.lastMessageId ?? lastMessageId,
      firstMessageId: r.firstMessageId,
      pinned: r.pinned,
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
}
