// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomHiveAdapter extends TypeAdapter<RoomHive> {
  @override
  final int typeId = 14;

  @override
  RoomHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomHive(
      uid: fields[0] as String,
      lastMessage: fields[1] as String?,
      draft: fields[5] as String?,
      lastUpdateTime: fields[6] as int,
      lastMessageId: fields[4] as int,
      localNetworkMessageCount: fields[16] as int,
      lastLocalNetworkMessageId: fields[17] as int,
      firstMessageId: fields[7] as int,
      deleted: fields[2] as bool,
      pinned: fields[8] as bool,
      pinId: fields[9] as int,
      synced: fields[10] as bool,
      lastCurrentUserSentMessageId: fields[11] as int,
      seenSynced: fields[12] as bool,
      replyKeyboardMarkup: fields[13] as String?,
      mentionsId: (fields[14] as List?)?.cast<int>(),
      shouldUpdateMediaCount: fields[15] as bool,
      localChatId: fields[18] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RoomHive obj) {
    writer
      ..writeByte(18)
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
      ..writeByte(12)
      ..write(obj.seenSynced)
      ..writeByte(13)
      ..write(obj.replyKeyboardMarkup)
      ..writeByte(14)
      ..write(obj.mentionsId)
      ..writeByte(15)
      ..write(obj.shouldUpdateMediaCount)
      ..writeByte(16)
      ..write(obj.localNetworkMessageCount)
      ..writeByte(17)
      ..write(obj.lastLocalNetworkMessageId)
      ..writeByte(18)
      ..write(obj.localChatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
