// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BroadcastStatusAdapter extends TypeAdapter<BroadcastStatus> {
  @override
  final int typeId = 40;

  @override
  BroadcastStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BroadcastStatus(
      broadcastMessageId: fields[0] as int,
      to: fields[1] as String,
      status: fields[2] as BroadcastMessageStatusType,
      sendingId: fields[3] as String,
      isSmsBroadcast: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BroadcastStatus obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.broadcastMessageId)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.sendingId)
      ..writeByte(4)
      ..write(obj.isSmsBroadcast);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BroadcastStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
