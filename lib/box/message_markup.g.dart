// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_markup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageMarkupAdapter extends TypeAdapter<MessageMarkup> {
  @override
  final int typeId = 30;

  @override
  MessageMarkup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageMarkup(
      inlineKeyboardMarkup: fields[0] as InlineKeyboardMarkup?,
      inputFieldPlaceHolder: fields[4] as String,
      inputSuggestions: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MessageMarkup obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.inlineKeyboardMarkup)
      ..writeByte(3)
      ..write(obj.inputSuggestions)
      ..writeByte(4)
      ..write(obj.inputFieldPlaceHolder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageMarkupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
