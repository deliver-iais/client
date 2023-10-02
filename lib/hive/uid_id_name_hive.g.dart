// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uid_id_name_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UidIdNameHiveAdapter extends TypeAdapter<UidIdNameHive> {
  @override
  final int typeId = 4;

  @override
  UidIdNameHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UidIdNameHive(
      uid: fields[0] as String,
      id: fields[1] as String?,
      name: fields[2] as String?,
      lastUpdate: fields[4] as int?,
      realName: fields[5] as String?,
      isContact: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UidIdNameHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.lastUpdate)
      ..writeByte(5)
      ..write(obj.realName)
      ..writeByte(6)
      ..write(obj.isContact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UidIdNameHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
