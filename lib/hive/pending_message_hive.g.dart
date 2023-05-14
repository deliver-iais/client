// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingMessageHiveAdapter extends TypeAdapter<PendingMessageHive> {
  @override
  final int typeId = 38;

  @override
  PendingMessageHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingMessageHive(
      roomUid: fields[0] as String,
      packetId: fields[1] as String,
      msg: fields[2] as String,
      failed: fields[3] as bool,
      messageId: fields[4] as int,
      status: fields[5] as SendingStatus,
    );
  }

  @override
  void write(BinaryWriter writer, PendingMessageHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.roomUid)
      ..writeByte(1)
      ..write(obj.packetId)
      ..writeByte(2)
      ..write(obj.msg)
      ..writeByte(3)
      ..write(obj.failed)
      ..writeByte(4)
      ..write(obj.messageId)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMessageHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
