// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallInfoAdapter extends TypeAdapter<CallInfo> {
  @override
  final int typeId = 20;

  @override
  CallInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallInfo(
      callEvent: fields[2] as CallEvent,
      from: fields[0] as String,
      to: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CallInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.callEvent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
