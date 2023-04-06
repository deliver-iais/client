// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_data_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallDataUsageAdapter extends TypeAdapter<CallDataUsage> {
  @override
  final int typeId = 37;

  @override
  CallDataUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallDataUsage(
      callId: fields[0] as String,
      byteSend: fields[1] as int,
      byteReceived: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CallDataUsage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.callId)
      ..writeByte(1)
      ..write(obj.byteSend)
      ..writeByte(2)
      ..write(obj.byteReceived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallDataUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
