// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_network_connections_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalNetworkConnectionsHiveAdapter
    extends TypeAdapter<LocalNetworkConnectionsHive> {
  @override
  final int typeId = 46;

  @override
  LocalNetworkConnectionsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalNetworkConnectionsHive(
      uid: fields[0] as String,
      lastUpdateTime: fields[1] as int?,
      backupLocalMessage: fields[2] as bool?,
      ip: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalNetworkConnectionsHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.lastUpdateTime)
      ..writeByte(2)
      ..write(obj.backupLocalMessage)
      ..writeByte(3)
      ..write(obj.ip);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalNetworkConnectionsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
