// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 11;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      roomUid: fields[0] as String,
      packetId: fields[2] as String,
      time: fields[3] as int,
      from: fields[4] as String,
      to: fields[5] as String,
      json: fields[11] as String,
      isHidden: fields[12] as bool,
      id: fields[1] as int?,
      type: fields[10] as MessageType,
      replyToId: fields[6] as int,
      edited: fields[8] as bool,
      encrypted: fields[9] as bool,
      forwardedFrom: fields[7] as String?,
      markup: fields[13] as String?,
      generatedBy: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.roomUid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.packetId)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.from)
      ..writeByte(5)
      ..write(obj.to)
      ..writeByte(6)
      ..write(obj.replyToId)
      ..writeByte(7)
      ..write(obj.forwardedFrom)
      ..writeByte(8)
      ..write(obj.edited)
      ..writeByte(9)
      ..write(obj.encrypted)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.json)
      ..writeByte(12)
      ..write(obj.isHidden)
      ..writeByte(13)
      ..write(obj.markup)
      ..writeByte(14)
      ..write(obj.generatedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      roomUid: json['roomUid'] as String,
      packetId: json['packetId'] as String,
      time: json['time'] as int,
      from: json['from'] as String,
      to: json['to'] as String,
      json: json['json'] as String,
      isHidden: json['isHidden'] as bool,
      id: json['id'] as int?,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.NOT_SET,
      replyToId: json['replyToId'] as int? ?? 0,
      edited: json['edited'] as bool? ?? false,
      encrypted: json['encrypted'] as bool? ?? false,
      forwardedFrom: json['forwardedFrom'] as String?,
      markup: json['markup'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'roomUid': instance.roomUid,
      'id': instance.id,
      'packetId': instance.packetId,
      'time': instance.time,
      'from': instance.from,
      'to': instance.to,
      'replyToId': instance.replyToId,
      'forwardedFrom': instance.forwardedFrom,
      'edited': instance.edited,
      'encrypted': instance.encrypted,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'json': instance.json,
      'isHidden': instance.isHidden,
      'markup': instance.markup,
    };

const _$MessageTypeEnumMap = {
  MessageType.TEXT: 'TEXT',
  MessageType.FILE: 'FILE',
  MessageType.STICKER: 'STICKER',
  MessageType.LOCATION: 'LOCATION',
  MessageType.LIVE_LOCATION: 'LIVE_LOCATION',
  MessageType.POLL: 'POLL',
  MessageType.FORM: 'FORM',
  MessageType.PERSISTENT_EVENT: 'PERSISTENT_EVENT',
  MessageType.NOT_SET: 'NOT_SET',
  MessageType.BUTTONS: 'BUTTONS',
  MessageType.SHARE_UID: 'SHARE_UID',
  MessageType.FORM_RESULT: 'FORM_RESULT',
  MessageType.SHARE_PRIVATE_DATA_REQUEST: 'SHARE_PRIVATE_DATA_REQUEST',
  MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE: 'SHARE_PRIVATE_DATA_ACCEPTANCE',
  MessageType.CALL: 'CALL',
  MessageType.TABLE: 'TABLE',
  MessageType.TRANSACTION: 'TRANSACTION',
  MessageType.PAYMENT_INFORMATION: 'PAYMENT_INFORMATION',
  MessageType.CALL_LOG: 'CALL_LOG',
};
