// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_uid.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdUidAdapter extends TypeAdapter<IdUid> {
  @override
  final int typeId = 5;

  @override
  IdUid read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdUid(
      id: fields[0] as String,
      uid: fields[1] as String,
      lastUpdate: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, IdUid obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(3)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdUidAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
