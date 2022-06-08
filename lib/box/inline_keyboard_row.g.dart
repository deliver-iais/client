// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_keyboard_row.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InlineKeyboardRowAdapter extends TypeAdapter<InlineKeyboardRow> {
  @override
  final int typeId = 32;

  @override
  InlineKeyboardRow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InlineKeyboardRow(
      buttons: (fields[0] as List).cast<InlineKeyboardButton>(),
    );
  }

  @override
  void write(BinaryWriter writer, InlineKeyboardRow obj) {
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
      other is InlineKeyboardRowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
