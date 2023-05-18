// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_verified_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IsVerifiedHiveAdapter extends TypeAdapter<IsVerifiedHive> {
  @override
  final int typeId = 42;

  @override
  IsVerifiedHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IsVerifiedHive(
      uid: fields[0] as String,
      lastUpdate: fields[1] as int,
      expireTime: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, IsVerifiedHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastUpdate)
      ..writeByte(2)
      ..write(obj.expireTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IsVerifiedHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
