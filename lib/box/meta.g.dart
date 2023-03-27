// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetaAdapter extends TypeAdapter<Meta> {
  @override
  final int typeId = 16;

  @override
  Meta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meta(
      createdOn: fields[0] as int,
      json: fields[2] as String,
      roomId: fields[3] as String,
      messageId: fields[4] as int,
      type: fields[5] as MetaType,
      createdBy: fields[1] as String,
      index: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Meta obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.createdOn)
      ..writeByte(1)
      ..write(obj.createdBy)
      ..writeByte(2)
      ..write(obj.json)
      ..writeByte(3)
      ..write(obj.roomId)
      ..writeByte(4)
      ..write(obj.messageId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
