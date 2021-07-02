// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muc.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MucAdapter extends TypeAdapter<Muc> {
  @override
  final int typeId = 7;

  @override
  Muc read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Muc(
      uid: fields[0] as String,
      name: fields[1] as String,
      token: fields[2] as String,
      id: fields[3] as String,
      info: fields[4] as String,
      pinMessagesIdList: (fields[5] as List)?.cast<int>(),
      population: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Muc obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.token)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.info)
      ..writeByte(5)
      ..write(obj.pinMessagesIdList)
      ..writeByte(6)
      ..write(obj.population);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MucAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
