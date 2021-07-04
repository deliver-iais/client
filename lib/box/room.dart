import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/shared/constants.dart';
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

  Room({
    this.uid,
    this.lastMessage,
    this.deleted,
    this.mentioned,
  });
}
