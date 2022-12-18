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
      lastUpdateTime: fields[6] as int,
      lastMessageId: fields[4] as int,
      firstMessageId: fields[7] as int,
      deleted: fields[2] as bool,
      pinned: fields[8] as bool,
      pinId: fields[9] as int,
      synced: fields[10] as bool,
      lastCurrentUserSentMessageId: fields[11] as int,
      replyKeyboardMarkup: fields[13] as String?,
      mentionsId: (fields[14] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Room obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastMessage)
      ..writeByte(2)
      ..write(obj.deleted)
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
      ..write(obj.pinId)
      ..writeByte(10)
      ..write(obj.synced)
      ..writeByte(11)
      ..write(obj.lastCurrentUserSentMessageId)
      ..writeByte(13)
      ..write(obj.replyKeyboardMarkup)
      ..writeByte(14)
      ..write(obj.mentionsId);
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
