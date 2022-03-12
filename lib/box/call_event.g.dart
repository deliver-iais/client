// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallEventAdapter extends TypeAdapter<CallEvent> {
  @override
  final int typeId = 21;

  @override
  CallEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallEvent(
      callDuration: fields[1] as int,
      endOfCallTime: fields[0] as int,
      callType: fields[2] as CallType,
      newStatus: fields[3] as CallStatus,
      id: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CallEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.endOfCallTime)
      ..writeByte(1)
      ..write(obj.callDuration)
      ..writeByte(2)
      ..write(obj.callType)
      ..writeByte(3)
      ..write(obj.newStatus)
      ..writeByte(4)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
