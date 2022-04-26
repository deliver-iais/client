// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_download.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AutoDownloadAdapter extends TypeAdapter<AutoDownload> {
  @override
  final int typeId = 25;

  @override
  AutoDownload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutoDownload(
      photoAutoDownload: fields[0] as bool,
      fileAutoDownload: fields[1] as bool,
      fileAutoDownloadSize: fields[2] as int,
      roomCategory: fields[3] as AutoDownloadRoomCategory,
    );
  }

  @override
  void write(BinaryWriter writer, AutoDownload obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.photoAutoDownload)
      ..writeByte(1)
      ..write(obj.fileAutoDownload)
      ..writeByte(2)
      ..write(obj.fileAutoDownloadSize)
      ..writeByte(3)
      ..write(obj.roomCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoDownloadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
