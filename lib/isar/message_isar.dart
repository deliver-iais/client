import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'message_isar.g.dart';

@collection
class MessageIsar {
  Id dbId = Isar.autoIncrement;

  @Index(type: IndexType.hash)
  final String roomUid;

  int? id;

  String packetId;

  int time;

  String from;

  String to;

  int replyToId;

  String? forwardedFrom;

  bool edited;

  bool encrypted;

  @enumerated
  MessageType type;

  String json;

  bool isHidden;

  String? markup;

  String? generatedBy;

  MessageIsar({
    required this.roomUid,
    this.id,
    required this.packetId,
    required this.time,
    required this.from,
    required this.to,
    this.replyToId = 0,
    this.forwardedFrom,
    this.edited = false,
    this.encrypted = false,
    this.type = MessageType.NOT_SET,
    required this.json,
    this.isHidden = false,
    this.markup,
    this.generatedBy,
  });

  Message fromIsar() => Message(
        roomUid: roomUid.asUid(),
        from: from.asUid(),
        to: to.asUid(),
        packetId: packetId,
        time: time,
        json: json,
        isHidden: isHidden,
        markup: markup,
        edited: edited,
        encrypted: encrypted,
        forwardedFrom: forwardedFrom?.asUid(),
        replyToId: replyToId,
        type: type,
        id: id,
        generatedBy: generatedBy?.asUid(),
      );
}

extension MessageIsarMapper on Message {
  MessageIsar toIsar() => MessageIsar(
        roomUid: roomUid.asString(),
        packetId: packetId,
        time: time,
        from: from.asString(),
        to: to.asString(),
        json: json,
        id: id,
        isHidden: isHidden,
        markup: markup,
        edited: edited,
        encrypted: encrypted,
        type: type,
        replyToId: replyToId,
        generatedBy: generatedBy?.asString(),
        forwardedFrom: forwardedFrom?.asString(),
      );
}
