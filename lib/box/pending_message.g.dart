// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingMessageAdapter extends TypeAdapter<PendingMessage> {
  @override
  final int typeId = 13;

  @override
  PendingMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingMessage(
      roomUid: fields[0] as String,
      packetId: fields[1] as String,
      msg: fields[2] as Message,
      failed: fields[3] as int,
      retries: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.roomUid)
      ..writeByte(1)
      ..write(obj.packetId)
      ..writeByte(2)
      ..write(obj.msg)
      ..writeByte(3)
      ..write(obj.failed)
      ..writeByte(4)
      ..write(obj.retries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
