// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BotInfoAdapter extends TypeAdapter<BotInfo> {
  @override
  final int typeId = 9;

  @override
  BotInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BotInfo(
      uid: fields[0] as String,
      description: fields[1] as String,
      name: fields[2] as String,
      commands: (fields[3] as Map)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BotInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.commands);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BotInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
