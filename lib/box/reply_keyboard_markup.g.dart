// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_keyboard_markup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReplyKeyboardMarkupAdapter extends TypeAdapter<ReplyKeyboardMarkup> {
  @override
  final int typeId = 34;

  @override
  ReplyKeyboardMarkup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReplyKeyboardMarkup(
      rows: (fields[0] as List).cast<ReplyKeyboardRow>(),
      inputFieldPlaceHolder: fields[2] as String,
      inputSuggestions: (fields[3] as List).cast<String>(),
      oneTimeKeyboard: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReplyKeyboardMarkup obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.rows)
      ..writeByte(1)
      ..write(obj.oneTimeKeyboard)
      ..writeByte(2)
      ..write(obj.inputFieldPlaceHolder)
      ..writeByte(3)
      ..write(obj.inputSuggestions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyKeyboardMarkupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
