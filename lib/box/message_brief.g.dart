// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_brief.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageBriefAdapter extends TypeAdapter<MessageBrief> {
  @override
  final int typeId = 28;

  @override
  MessageBrief read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageBrief(
      roomUid: fields[0] as String,
      packetId: fields[1] as String,
      id: fields[2] as int,
      time: fields[3] as int,
      from: fields[4] as String,
      to: fields[5] as String,
      text: fields[6] as String,
      type: fields[7] as MessageType,
    );
  }

  @override
  void write(BinaryWriter writer, MessageBrief obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.roomUid)
      ..writeByte(1)
      ..write(obj.packetId)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.from)
      ..writeByte(5)
      ..write(obj.to)
      ..writeByte(6)
      ..write(obj.text)
      ..writeByte(7)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageBriefAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
