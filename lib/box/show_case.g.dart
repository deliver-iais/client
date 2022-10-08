// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_case.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShowCaseAdapter extends TypeAdapter<ShowCase> {
  @override
  final int typeId = 37;

  @override
  ShowCase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShowCase(
      index: fields[0] as int,
      json: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShowCase obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.index)
      ..writeByte(1)
      ..write(obj.json);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowCaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
