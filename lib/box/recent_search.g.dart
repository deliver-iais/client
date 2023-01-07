// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentSearchAdapter extends TypeAdapter<RecentSearch> {
  @override
  final int typeId = 36;

  @override
  RecentSearch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentSearch(
      roomId: fields[0] as String,
      time: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecentSearch obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentSearchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
