// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActiveNotificationAdapter extends TypeAdapter<ActiveNotification> {
  @override
  final int typeId = 37;

  @override
  ActiveNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveNotification(
      roomUid: fields[0] as String,
      messageId: fields[1] as int,
      messageText: fields[3] as String,
      roomName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveNotification obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.roomUid)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.roomName)
      ..writeByte(3)
      ..write(obj.messageText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
