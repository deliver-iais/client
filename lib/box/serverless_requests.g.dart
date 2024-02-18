// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serverless_requests.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerLessRequestAdapter extends TypeAdapter<ServerLessRequest> {
  @override
  final int typeId = 47;

  @override
  ServerLessRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerLessRequest(
      uid: fields[0] as String,
      info: fields[1] as String,
      time: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ServerLessRequest obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.info)
      ..writeByte(2)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerLessRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
