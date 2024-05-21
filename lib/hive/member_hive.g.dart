// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberHiveAdapter extends TypeAdapter<MemberHive> {
  @override
  final int typeId = 8;

  @override
  MemberHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberHive(
      mucUid: fields[0] as String,
      memberUid: fields[1] as String,
      id: fields[3] as String,
      name: fields[4] as String,
      role: fields[2] as MucRole,
    );
  }

  @override
  void write(BinaryWriter writer, MemberHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.mucUid)
      ..writeByte(1)
      ..write(obj.memberUid)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
