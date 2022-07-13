// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_meta_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaMetaDataAdapter extends TypeAdapter<MediaMetaData> {
  @override
  final int typeId = 17;

  @override
  MediaMetaData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaMetaData(
      roomId: fields[0] as String,
      imagesCount: fields[1] as int,
      videosCount: fields[2] as int,
      filesCount: fields[3] as int,
      documentsCount: fields[4] as int,
      audiosCount: fields[5] as int,
      musicsCount: fields[6] as int,
      linkCount: fields[7] as int,
      lastUpdateTime: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MediaMetaData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.imagesCount)
      ..writeByte(2)
      ..write(obj.videosCount)
      ..writeByte(3)
      ..write(obj.filesCount)
      ..writeByte(4)
      ..write(obj.documentsCount)
      ..writeByte(5)
      ..write(obj.audiosCount)
      ..writeByte(6)
      ..write(obj.musicsCount)
      ..writeByte(7)
      ..write(obj.linkCount)
      ..writeByte(8)
      ..write(obj.lastUpdateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaMetaDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
