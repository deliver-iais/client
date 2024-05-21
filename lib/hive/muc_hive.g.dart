// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muc_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MucHiveAdapter extends TypeAdapter<MucHive> {
  @override
  final int typeId = 7;

  @override
  MucHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MucHive(
      uid: fields[0] as String,
      name: fields[1] as String,
      token: fields[2] as String,
      id: fields[3] as String,
      info: fields[4] as String,
      synced: fields[10] as bool,
      lastUpdateTime: fields[11] as int,
      pinMessagesIdList: (fields[5] as List).cast<int>(),
      population: fields[6] as int,
      lastCanceledPinMessageId: fields[7] as int,
      mucType: fields[8] as MucType,
      currentUserRole: fields[9] as MucRole,
    );
  }

  @override
  void write(BinaryWriter writer, MucHive obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.population)
      ..writeByte(7)
      ..write(obj.lastCanceledPinMessageId)
      ..writeByte(8)
      ..write(obj.mucType)
      ..writeByte(9)
      ..write(obj.currentUserRole)
      ..writeByte(10)
      ..write(obj.synced)
      ..writeByte(11)
      ..write(obj.lastUpdateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MucHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
