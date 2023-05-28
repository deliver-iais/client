// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_call_status_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LastCallStatusHiveAdapter extends TypeAdapter<LastCallStatusHive> {
  @override
  final int typeId = 43;

  @override
  LastCallStatusHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LastCallStatusHive(
      id: fields[0] as String,
      callId: fields[1] as String,
      roomUid: fields[2] as String,
      expireTime: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LastCallStatusHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.callId)
      ..writeByte(2)
      ..write(obj.roomUid)
      ..writeByte(3)
      ..write(obj.expireTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastCallStatusHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
