// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaTypeAdapter extends TypeAdapter<MediaType> {
  @override
  final int typeId = 18;

  @override
  MediaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaType.IMAGE;
      case 1:
        return MediaType.VIDEO;
      case 2:
        return MediaType.FILE;
      case 3:
        return MediaType.AUDIO;
      case 4:
        return MediaType.MUSIC;
      case 5:
        return MediaType.DOCUMENT;
      case 6:
        return MediaType.LINK;
      case 7:
        return MediaType.NOT_SET;
      default:
        return MediaType.IMAGE;
    }
  }

  @override
  void write(BinaryWriter writer, MediaType obj) {
    switch (obj) {
      case MediaType.IMAGE:
        writer.writeByte(0);
        break;
      case MediaType.VIDEO:
        writer.writeByte(1);
        break;
      case MediaType.FILE:
        writer.writeByte(2);
        break;
      case MediaType.AUDIO:
        writer.writeByte(3);
        break;
      case MediaType.MUSIC:
        writer.writeByte(4);
        break;
      case MediaType.DOCUMENT:
        writer.writeByte(5);
        break;
      case MediaType.LINK:
        writer.writeByte(6);
        break;
      case MediaType.NOT_SET:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
