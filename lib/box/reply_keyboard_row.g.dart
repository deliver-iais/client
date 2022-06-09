// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_keyboard_row.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReplyKeyboardRowAdapter extends TypeAdapter<ReplyKeyboardRow> {
  @override
  final int typeId = 35;

  @override
  ReplyKeyboardRow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReplyKeyboardRow(
      buttons: (fields[0] as List).cast<ReplyKeyboardButton>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReplyKeyboardRow obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.buttons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyKeyboardRowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
