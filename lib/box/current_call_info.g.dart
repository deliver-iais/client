// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_call_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentCallInfoAdapter extends TypeAdapter<CurrentCallInfo> {
  @override
  final int typeId = 27;

  @override
  CurrentCallInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentCallInfo(
      callEvent: fields[2] as CallEvent,
      from: fields[0] as String,
      to: fields[1] as String,
      expireTime: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentCallInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.callEvent)
      ..writeByte(3)
      ..write(obj.expireTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentCallInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
