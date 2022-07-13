// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LastActivityAdapter extends TypeAdapter<LastActivity> {
  @override
  final int typeId = 2;

  @override
  LastActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LastActivity(
      uid: fields[0] as String,
      time: fields[1] as int,
      lastUpdate: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LastActivity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
