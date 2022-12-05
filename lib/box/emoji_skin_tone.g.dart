// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_skin_tone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmojiSkinToneAdapter extends TypeAdapter<EmojiSkinTone> {
  @override
  final int typeId = 34;

  @override
  EmojiSkinTone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmojiSkinTone(
      char: fields[0] as String,
      tone: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EmojiSkinTone obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.char)
      ..writeByte(1)
      ..write(obj.tone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmojiSkinToneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
