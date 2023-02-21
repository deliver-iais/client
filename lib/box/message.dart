import 'package:collection/collection.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: MESSAGE_TRACK_ID)
class Message {
  @HiveField(0)
  String roomUid;

  @HiveField(1)
  int? id;

  @HiveField(2)
  String packetId;

  @HiveField(3)
  int time;

  @HiveField(4)
  String from;

  @HiveField(5)
  String to;

  @HiveField(6)
  int replyToId;

  @HiveField(7)
  String? forwardedFrom;

  @HiveField(8)
  bool edited;

  @HiveField(9)
  bool encrypted;

  @HiveField(10)
  MessageType type;

  @HiveField(11)
  String json;

  @HiveField(12)
  bool isHidden;

  @HiveField(13)
  String? markup;

  Message({
    required this.roomUid,
    required this.packetId,
    required this.time,
    required this.from,
    required this.to,
    required this.json,
    required this.isHidden,
    this.id,
    this.type = MessageType.NOT_SET,
    this.replyToId = 0,
    this.edited = false,
    this.encrypted = false,
    this.forwardedFrom,
    this.markup,
  });

  Message copyDeleted() => copyWith(json: EMPTY_MESSAGE, isHidden: true);

  Message copyWith({
    String? roomUid,
    int? id,
    String? packetId,
    int? time,
    String? from,
    String? to,
    int? replyToId,
    String? forwardedFrom,
    bool? isHidden,
    bool? edited,
    bool? encrypted,
    MessageType? type,
    String? json,
    String? markup,
  }) =>
      Message(
        roomUid: roomUid ?? this.roomUid,
        id: id ?? this.id,
        packetId: packetId ?? this.packetId,
        time: time ?? this.time,
        from: from ?? this.from,
        to: to ?? this.to,
        replyToId: replyToId ?? this.replyToId,
        forwardedFrom: forwardedFrom ?? this.forwardedFrom,
        isHidden: isHidden ?? this.isHidden,
        edited: edited ?? this.edited,
        encrypted: encrypted ?? this.encrypted,
        type: type ?? this.type,
        json: json ?? this.json,
        markup: markup ?? this.markup,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is Message &&
          const DeepCollectionEquality().equals(other.roomUid, roomUid) &&
          const DeepCollectionEquality().equals(other.id, id) &&
          const DeepCollectionEquality().equals(other.packetId, packetId) &&
          const DeepCollectionEquality().equals(other.time, time) &&
          const DeepCollectionEquality().equals(other.from, from) &&
          const DeepCollectionEquality().equals(other.to, to) &&
          const DeepCollectionEquality().equals(other.replyToId, replyToId) &&
          const DeepCollectionEquality().equals(other.isHidden, isHidden) &&
          const DeepCollectionEquality()
              .equals(other.forwardedFrom, forwardedFrom) &&
          const DeepCollectionEquality().equals(other.edited, edited) &&
          const DeepCollectionEquality().equals(other.encrypted, encrypted) &&
          const DeepCollectionEquality().equals(other.type, type) &&
          const DeepCollectionEquality().equals(other.json, json));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(roomUid),
        const DeepCollectionEquality().hash(id),
        const DeepCollectionEquality().hash(packetId),
        const DeepCollectionEquality().hash(time),
        const DeepCollectionEquality().hash(from),
        const DeepCollectionEquality().hash(to),
        const DeepCollectionEquality().hash(replyToId),
        const DeepCollectionEquality().hash(forwardedFrom),
        const DeepCollectionEquality().hash(isHidden),
        const DeepCollectionEquality().hash(edited),
        const DeepCollectionEquality().hash(encrypted),
        const DeepCollectionEquality().hash(type),
        const DeepCollectionEquality().hash(json),
      );

  @override
  String toString() {
    return "Message([roomUid:$roomUid] [id:$id] [packetId:$packetId] [time:$time] [from:$from] [to:$to] [replyToId:$replyToId] [forwardedFrom:$forwardedFrom] [isHidden:$isHidden] [edited:$edited] [encrypted:$encrypted] [type:$type] [json:$json] [markup:$markup]}";
  }
}
