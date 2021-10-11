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

  @HiveField(8)
  bool pinned;

  Room(
      {this.uid,
      this.lastMessage,
      this.deleted,
      this.mentioned,
      this.draft,
      this.lastUpdateTime,
      this.lastMessageId,
      this.firstMessageId,
      this.pinned});

  Room copy(Room r) => Room(
      uid: r.uid ?? this.uid,
      lastMessage: r.lastMessage ?? this.lastMessage,
      deleted: r.deleted ?? this.deleted,
      draft: r.draft ?? this.draft,
      lastUpdateTime: r.lastUpdateTime ?? this.lastUpdateTime,
      mentioned: r.mentioned ?? this.mentioned,
      lastMessageId: r.lastMessageId ?? this.lastMessageId,
      firstMessageId: r.firstMessageId ?? this.firstMessageId,
      pinned: r.pinned ?? this.pinned);

  Room copyWith(
          {String uid,
          Message lastMessage,
          int lastMessageId,
          bool deleted,
          String draft,
          int lastUpdateTime,
          int firstMessageId,
          bool mentioned,
          bool pinned}) =>
      Room(
          uid: uid ?? this.uid,
          lastMessage: lastMessage ?? this.lastMessage,
          deleted: deleted ?? this.deleted,
          draft: draft ?? this.draft,
          lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
          mentioned: mentioned ?? this.mentioned,
          firstMessageId: firstMessageId ?? this.firstMessageId,
          lastMessageId: lastMessageId ?? this.lastMessageId,
          pinned: pinned ?? this.pinned);
}
