// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomAdapter extends TypeAdapter<Room> {
  @override
  final int typeId = 14;

  @override
  Room read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Room(
      uid: fields[0] as String,
      lastMessage: fields[1] as Message?,
      draft: fields[5] as String?,
      lastUpdateTime: fields[6] as int?,
      lastMessageId: fields[4] as int?,
      firstMessageId: fields[7] as int,
      mentioned: fields[3] as bool,
      deleted: fields[2] as bool,
      pinned: fields[8] as bool,
      lastUpdatedMessageId: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Room obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastMessage)
      ..writeByte(2)
      ..write(obj.deleted)
      ..writeByte(3)
      ..write(obj.mentioned)
      ..writeByte(4)
      ..write(obj.lastMessageId)
      ..writeByte(5)
      ..write(obj.draft)
      ..writeByte(6)
      ..write(obj.lastUpdateTime)
      ..writeByte(7)
      ..write(obj.firstMessageId)
      ..writeByte(8)
      ..write(obj.pinned)
      ..writeByte(9)
      ..write(obj.lastUpdatedMessageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
