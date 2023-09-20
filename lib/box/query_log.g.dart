// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueryLogAdapter extends TypeAdapter<QueryLog> {
  @override
  final int typeId = 45;

  @override
  QueryLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueryLog(
      address: fields[0] as String,
      count: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QueryLog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
