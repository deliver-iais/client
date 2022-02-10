// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvatarAdapter extends TypeAdapter<Avatar> {
  @override
  final int typeId = 1;

  @override
  Avatar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Avatar(
      uid: fields[0] as String,
      createdOn: fields[1] as int,
      fileId: fields[2] as String?,
      fileName: fields[3] as String?,
      lastUpdate: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Avatar obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.createdOn)
      ..writeByte(2)
      ..write(obj.fileId)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
