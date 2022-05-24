// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_brief.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageBriefAdapter extends TypeAdapter<MessageReplyBrief> {
  @override
  final int typeId = 28;

  @override
  MessageReplyBrief read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageReplyBrief(
      roomUid: fields[0] as String,
      id: fields[1] as int,
      time: fields[2] as int,
      from: fields[3] as String,
      to: fields[4] as String,
      text: fields[5] as String,
      type: fields[6] as MessageType,
    );
  }

  @override
  void write(BinaryWriter writer, MessageReplyBrief obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.roomUid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.from)
      ..writeByte(4)
      ..write(obj.to)
      ..writeByte(5)
      ..write(obj.text)
      ..writeByte(6)
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
