import 'package:we/box/message.dart';
import 'package:we/shared/constants.dart';
import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: ROOM_METADATA_TRACK_ID)
class Room {
  // Table ID
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  Message lastMessage;

  @HiveField(2)
  bool deleted;

  @HiveField(3)
  bool mentioned;

  @HiveField(4)
  int lastMessageId;

  @HiveField(5)
  String draft;

  @HiveField(6)
  int lastUpdateTime;

  @HiveField(7)
  int firstMessageId;

  Room(
      {this.uid,
      this.lastMessage,
      this.deleted,
      this.mentioned,
      this.draft,
      this.lastUpdateTime,
      this.lastMessageId,
      this.firstMessageId});

  Room copy(Room r) => Room(
      uid: r.uid ?? this.uid,
      lastMessage: r.lastMessage ?? this.lastMessage,
      deleted: r.deleted ?? this.deleted,
      draft: r.draft ?? this.draft,
      lastUpdateTime: r.lastUpdateTime ?? this.lastUpdateTime,
      mentioned: r.mentioned ?? this.mentioned,
      lastMessageId: r.lastMessageId ?? this.lastMessageId,
      firstMessageId: r.firstMessageId ?? this.firstMessageId);

  Room copyWith(
          {String uid,
          Message lastMessage,
          int lastMessageId,
          bool deleted,
          String draft,
          int lastUpdateTime,
          int firstMessageId,
          bool mentioned}) =>
      Room(
          uid: uid ?? this.uid,
          lastMessage: lastMessage ?? this.lastMessage,
          deleted: deleted ?? this.deleted,
          draft: draft ?? this.draft,
          lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
          mentioned: mentioned ?? this.mentioned,
          firstMessageId: firstMessageId ?? this.firstMessageId,
          lastMessageId: lastMessageId ?? this.lastMessageId);
}
