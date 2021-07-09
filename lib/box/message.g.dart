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
      id: fields[1] as int,
      packetId: fields[2] as String,
      time: fields[3] as int,
      from: fields[4] as String,
      to: fields[5] as String,
      replyToId: fields[6] as int,
      forwardedFrom: fields[7] as String,
      edited: fields[8] as bool,
      encrypted: fields[9] as bool,
      type: fields[10] as MessageType,
      json: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.json);
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
