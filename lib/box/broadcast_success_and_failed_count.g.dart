// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_success_and_failed_count.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BroadcastSuccessAndFailedCountAdapter
    extends TypeAdapter<BroadcastSuccessAndFailedCount> {
  @override
  final int typeId = 39;

  @override
  BroadcastSuccessAndFailedCount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BroadcastSuccessAndFailedCount(
      broadcastSuccessCount: fields[0] as int,
      broadcastFailedCount: fields[1] as int,
      broadcastMessageId: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BroadcastSuccessAndFailedCount obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.broadcastSuccessCount)
      ..writeByte(1)
      ..write(obj.broadcastFailedCount)
      ..writeByte(2)
      ..write(obj.broadcastMessageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BroadcastSuccessAndFailedCountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
