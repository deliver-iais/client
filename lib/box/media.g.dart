// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 16;

  @override
  Media read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Media(
      createdOn: fields[0] as int,
      json: fields[2] as String,
      roomId: fields[3] as String,
      messageId: fields[4] as int,
      type: fields[5] as MediaType,
      createdBy: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
