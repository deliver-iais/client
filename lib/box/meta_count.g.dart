// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_count.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetaCountAdapter extends TypeAdapter<MetaCount> {
  @override
  final int typeId = 17;

  @override
  MetaCount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetaCount(
      roomId: fields[0] as String,
      mediasCount: fields[1] as int,
      callsCount: fields[3] as int,
      filesCount: fields[2] as int,
      voicesCount: fields[4] as int,
      musicsCount: fields[5] as int,
      linkCount: fields[6] as int,
      allCallDeletedCount: fields[12] as int,
      allFilesDeletedCount: fields[8] as int,
      allLinksDeletedCount: fields[11] as int,
      allMediaDeletedCount: fields[7] as int,
      allMusicsDeletedCount: fields[9] as int,
      allVoicesDeletedCount: fields[10] as int,
      lastUpdateTime: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MetaCount obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.mediasCount)
      ..writeByte(2)
      ..write(obj.filesCount)
      ..writeByte(3)
      ..write(obj.callsCount)
      ..writeByte(4)
      ..write(obj.voicesCount)
      ..writeByte(5)
      ..write(obj.musicsCount)
      ..writeByte(6)
      ..write(obj.linkCount)
      ..writeByte(7)
      ..write(obj.allMediaDeletedCount)
      ..writeByte(8)
      ..write(obj.allFilesDeletedCount)
      ..writeByte(9)
      ..write(obj.allMusicsDeletedCount)
      ..writeByte(10)
      ..write(obj.allVoicesDeletedCount)
      ..writeByte(11)
      ..write(obj.allLinksDeletedCount)
      ..writeByte(12)
      ..write(obj.allCallDeletedCount)
      ..writeByte(13)
      ..write(obj.lastUpdateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaCountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
