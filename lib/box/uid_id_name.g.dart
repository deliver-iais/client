// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uid_id_name.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UidIdNameAdapter extends TypeAdapter<UidIdName> {
  @override
  final int typeId = 4;

  @override
  UidIdName read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UidIdName(
      uid: fields[0] as String,
      id: fields[1] as String?,
      name: fields[2] as String?,
      lastUpdate: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UidIdName obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UidIdNameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
