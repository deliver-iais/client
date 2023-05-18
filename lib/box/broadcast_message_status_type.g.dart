// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_message_status_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BroadcastMessageStatusTypeAdapter
    extends TypeAdapter<BroadcastMessageStatusType> {
  @override
  final int typeId = 41;

  @override
  BroadcastMessageStatusType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BroadcastMessageStatusType.WAITING;
      case 1:
        return BroadcastMessageStatusType.SENDING;
      case 2:
        return BroadcastMessageStatusType.FAILED;
      default:
        return BroadcastMessageStatusType.WAITING;
    }
  }

  @override
  void write(BinaryWriter writer, BroadcastMessageStatusType obj) {
    switch (obj) {
      case BroadcastMessageStatusType.WAITING:
        writer.writeByte(0);
        break;
      case BroadcastMessageStatusType.SENDING:
        writer.writeByte(1);
        break;
      case BroadcastMessageStatusType.FAILED:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BroadcastMessageStatusTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
