// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_keyboard_button.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReplyKeyboardButtonAdapter extends TypeAdapter<ReplyKeyboardButton> {
  @override
  final int typeId = 36;

  @override
  ReplyKeyboardButton read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReplyKeyboardButton(
      text: fields[0] as String,
      sendOnClick: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReplyKeyboardButton obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.sendOnClick);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyKeyboardButtonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
