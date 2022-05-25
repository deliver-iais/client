import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

import 'message_type.dart';

part 'message_brief.g.dart';

@HiveType(typeId: MESSAGE_BRIEF_TRACK_ID)
class MessageBrief {
  @HiveField(0)
  String roomUid;

  @HiveField(1)
  String packetId;

  @HiveField(2)
  int id;

  @HiveField(3)
  int time;

  @HiveField(4)
  String from;

  @HiveField(5)
  String to;

  @HiveField(6)
  String text;

  @HiveField(7)
  MessageType type;

  MessageBrief({
    required this.roomUid,
    required this.packetId,
    required this.id,
    required this.time,
    required this.from,
    required this.to,
    required this.text,
    this.type = MessageType.NOT_SET,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is MessageBrief &&
          const DeepCollectionEquality().equals(other.roomUid, roomUid) &&
          const DeepCollectionEquality().equals(other.packetId, packetId) &&
          const DeepCollectionEquality().equals(other.id, id) &&
          const DeepCollectionEquality().equals(other.time, time) &&
          const DeepCollectionEquality().equals(other.from, from) &&
          const DeepCollectionEquality().equals(other.to, to) &&
          const DeepCollectionEquality().equals(other.type, type) &&
          const DeepCollectionEquality().equals(other.text, text));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(roomUid),
        const DeepCollectionEquality().hash(packetId),
        const DeepCollectionEquality().hash(id),
        const DeepCollectionEquality().hash(time),
        const DeepCollectionEquality().hash(from),
        const DeepCollectionEquality().hash(to),
        const DeepCollectionEquality().hash(type),
        const DeepCollectionEquality().hash(text),
      );
}
