// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_keyboard_button.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InlineKeyboardButtonAdapter extends TypeAdapter<InlineKeyboardButton> {
  @override
  final int typeId = 33;

  @override
  InlineKeyboardButton read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InlineKeyboardButton(
      text: fields[0] as String,
      json: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InlineKeyboardButton obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.json);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineKeyboardButtonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
