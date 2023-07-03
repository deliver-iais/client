// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallTypeAdapter extends TypeAdapter<CallType> {
  @override
  final int typeId = 23;

  @override
  CallType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallType.AUDIO;
      case 1:
        return CallType.VIDEO;
      case 2:
        return CallType.GROUP_VIDEO;
      case 3:
        return CallType.GROUP_AUDIO;
      default:
        return CallType.AUDIO;
    }
  }

  @override
  void write(BinaryWriter writer, CallType obj) {
    switch (obj) {
      case CallType.AUDIO:
        writer.writeByte(0);
        break;
      case CallType.VIDEO:
        writer.writeByte(1);
        break;
      case CallType.GROUP_VIDEO:
        writer.writeByte(2);
        break;
      case CallType.GROUP_AUDIO:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
