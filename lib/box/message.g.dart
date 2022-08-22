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
      markup: fields[13] as MessageMarkup?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.markup);
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
