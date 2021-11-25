import 'package:deliver/box/message_type.dart';
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
  int? replyToId;

  @HiveField(7)
  String? forwardedFrom;

  @HiveField(8)
  bool? edited;

  @HiveField(9)
  bool? encrypted;

  @HiveField(10)
  MessageType? type;

  @HiveField(11)
  String? json;

  Message(
      {required this.roomUid,
      this.id,
      required this.packetId,
      required this.time,
      required this.from,
      required this.to,
      this.replyToId,
      this.forwardedFrom,
      this.edited,
      this.encrypted,
      this.type,
      this.json});

  Message copy(Message pm) => Message(
        roomUid: pm.roomUid,
        id: pm.id ?? this.id,
        packetId: pm.packetId,
        time: pm.time,
        from: pm.from,
        to: pm.to,
        replyToId: pm.replyToId ?? this.replyToId,
        forwardedFrom: pm.forwardedFrom ?? this.forwardedFrom,
        edited: pm.edited ?? this.edited,
        encrypted: pm.encrypted ?? this.encrypted,
        type: pm.type,
        json: pm.json,
      );

  Message copyWith(
          {String? roomUid,
          int? id,
          String? packetId,
          int? time,
          String? from,
          String? to,
          int? replyToId,
          String? forwardedFrom,
          bool? edited,
          bool? encrypted,
          MessageType? type,
          String? json}) =>
      Message(
        roomUid: roomUid ?? this.roomUid,
        id: id ?? this.id,
        packetId: packetId ?? this.packetId,
        time: time ?? this.time,
        from: from ?? this.from,
        to: to ?? this.to,
        replyToId: replyToId ?? this.replyToId,
        forwardedFrom: forwardedFrom ?? this.forwardedFrom,
        edited: edited ?? this.edited,
        encrypted: encrypted ?? this.encrypted,
        type: type ?? this.type,
        json: json ?? this.json,
      );
}
