// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetaTypeAdapter extends TypeAdapter<MetaType> {
  @override
  final int typeId = 18;

  @override
  MetaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetaType.MEDIA;
      case 1:
        return MetaType.FILE;
      case 2:
        return MetaType.AUDIO;
      case 3:
        return MetaType.MUSIC;
      case 4:
        return MetaType.CALL;
      case 5:
        return MetaType.LINK;
      case 6:
        return MetaType.NOT_SET;
      default:
        return MetaType.MEDIA;
    }
  }

  @override
  void write(BinaryWriter writer, MetaType obj) {
    switch (obj) {
      case MetaType.MEDIA:
        writer.writeByte(0);
        break;
      case MetaType.FILE:
        writer.writeByte(1);
        break;
      case MetaType.AUDIO:
        writer.writeByte(2);
        break;
      case MetaType.MUSIC:
        writer.writeByte(3);
        break;
      case MetaType.CALL:
        writer.writeByte(4);
        break;
      case MetaType.LINK:
        writer.writeByte(5);
        break;
      case MetaType.NOT_SET:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
