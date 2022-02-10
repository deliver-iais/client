// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seen.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeenAdapter extends TypeAdapter<Seen> {
  @override
  final int typeId = 5;

  @override
  Seen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Seen(
      uid: fields[0] as String,
      messageId: fields[1] as int,
      hiddenMessageCount: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Seen obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.hiddenMessageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
