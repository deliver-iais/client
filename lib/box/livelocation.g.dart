// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livelocation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveLocationAdapter extends TypeAdapter<LiveLocation> {
  @override
  final int typeId = 19;

  @override
  LiveLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveLocation(
      uuid: fields[0] as String,
      lastUpdate: fields[2] as int,
      locations: (fields[3] as List).cast<Location>(),
      duration: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LiveLocation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.lastUpdate)
      ..writeByte(3)
      ..write(obj.locations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
