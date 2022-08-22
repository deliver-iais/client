// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_keyboard_markup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InlineKeyboardMarkupAdapter extends TypeAdapter<InlineKeyboardMarkup> {
  @override
  final int typeId = 31;

  @override
  InlineKeyboardMarkup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InlineKeyboardMarkup(
      rows: (fields[0] as List).cast<InlineKeyboardRow>(),
    );
  }

  @override
  void write(BinaryWriter writer, InlineKeyboardMarkup obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.rows);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineKeyboardMarkupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
