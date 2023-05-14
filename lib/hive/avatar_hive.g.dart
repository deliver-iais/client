// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvatarHiveAdapter extends TypeAdapter<AvatarHive> {
  @override
  final int typeId = 1;

  @override
  AvatarHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AvatarHive(
      uid: fields[0] as String,
      createdOn: fields[1] as int,
      fileId: fields[2] as String,
      fileName: fields[3] as String,
      lastUpdate: fields[4] as int,
      avatarIsEmpty: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AvatarHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.createdOn)
      ..writeByte(2)
      ..write(obj.fileId)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.lastUpdate)
      ..writeByte(5)
      ..write(obj.avatarIsEmpty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
