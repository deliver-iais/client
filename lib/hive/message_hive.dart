import 'package:collection/collection.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_hive.g.dart';

@JsonSerializable()
@HiveType(typeId: MESSAGE_TRACK_ID)
class MessageHive {
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

  @HiveField(14)
  String? generatedBy;

  @HiveField(15)
  int? localNetworkMessageId;

  MessageHive({
    required this.roomUid,
    required this.packetId,
    required this.time,
    required this.from,
    required this.to,
    required this.json,
    required this.isHidden,
    this.id,
    this.localNetworkMessageId,
    this.type = MessageType.NOT_SET,
    this.replyToId = 0,
    this.edited = false,
    this.encrypted = false,
    this.forwardedFrom,
    this.markup,
    this.generatedBy,
  });

  MessageHive copyWith({
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
    int? localNetworkMessageId,
    String? generatedBy,
  }) =>
      MessageHive(
        roomUid: roomUid ?? this.roomUid,
        id: id ?? this.id,
        localNetworkMessageId:
            localNetworkMessageId ?? this.localNetworkMessageId,
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
        generatedBy: generatedBy ?? this.generatedBy,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
              other is MessageHive &&
              const DeepCollectionEquality().equals(other.roomUid, roomUid) &&
              const DeepCollectionEquality().equals(other.id, id) &&
              const DeepCollectionEquality().equals(other.packetId, packetId) &&
              const DeepCollectionEquality().equals(other.time, time) &&
              const DeepCollectionEquality().equals(other.from, from) &&
              const DeepCollectionEquality().equals(other.to, to) &&
              const DeepCollectionEquality()
                  .equals(other.replyToId, replyToId) &&
              const DeepCollectionEquality().equals(other.isHidden, isHidden) &&
              const DeepCollectionEquality()
                  .equals(other.forwardedFrom, forwardedFrom) &&
              const DeepCollectionEquality().equals(other.edited, edited) &&
              const DeepCollectionEquality()
                  .equals(other.encrypted, encrypted) &&
              const DeepCollectionEquality().equals(other.type, type) &&
              const DeepCollectionEquality().equals(other.json, json)) &&
          const DeepCollectionEquality()
              .equals(other.generatedBy, generatedBy) &&
          const DeepCollectionEquality()
              .equals(other.localNetworkMessageId, localNetworkMessageId);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(roomUid),
        const DeepCollectionEquality().hash(id),
        const DeepCollectionEquality().hash(localNetworkMessageId),
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
        const DeepCollectionEquality().hash(generatedBy),
      );

  @override
  String toString() {
    return "Message([roomUid:$roomUid] [id:$id] [packetId:$packetId] [time:$time] [from:$from] [to:$to] [replyToId:$replyToId] [forwardedFrom:$forwardedFrom] [isHidden:$isHidden] [edited:$edited] [encrypted:$encrypted] [type:$type] [json:$json] [markup:$markup] [generatedBy:$generatedBy] [localNetworkMessageId:$localNetworkMessageId]}";
  }

  Message fromHive() => Message(
        roomUid: roomUid.asUid(),
        from: from.asUid(),
        to: to.asUid(),
        packetId: packetId,
        time: time,
        json: json,
        replyToId: replyToId,
        encrypted: encrypted,
        edited: edited,
        isHidden: isHidden,
        id: id,
        localNetworkMessageId: localNetworkMessageId,
        type: type,
        forwardedFrom: forwardedFrom?.asUid(),
        markup: markup,
        generatedBy: generatedBy?.asUid(),
      );
}

extension MessageHiveMapper on Message {
  MessageHive toHive() => MessageHive(
        roomUid: roomUid.asString(),
        from: from.asString(),
        to: to.asString(),
        packetId: packetId,
        time: time,
        json: json,
        replyToId: replyToId,
        encrypted: encrypted,
        edited: edited,
        isHidden: isHidden,
        id: id,
        localNetworkMessageId: localNetworkMessageId,
        type: type,
        forwardedFrom: forwardedFrom?.asString(),
        markup: markup,
        generatedBy: generatedBy?.asString(),
      );
}
