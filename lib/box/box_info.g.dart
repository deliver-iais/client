// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoxInfoAdapter extends TypeAdapter<BoxInfo> {
  @override
  final int typeId = 32;

  @override
  BoxInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxInfo(
      name: fields[0] as String,
      version: fields[1] as int,
      dbKey: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BoxInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.dbKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
