// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileInfoHiveAdapter extends TypeAdapter<FileInfoHive> {
  @override
  final int typeId = 6;

  @override
  FileInfoHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileInfoHive(
      sizeType: fields[0] as String,
      uuid: fields[1] as String,
      name: fields[2] as String,
      path: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FileInfoHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sizeType)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileInfoHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
