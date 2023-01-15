// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_rooms.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentRoomsAdapter extends TypeAdapter<RecentRooms> {
  @override
  final int typeId = 35;

  @override
  RecentRooms read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentRooms(
      roomId: fields[0] as String,
      count: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecentRooms obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentRoomsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
