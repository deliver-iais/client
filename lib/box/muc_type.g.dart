// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muc_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MucTypeAdapter extends TypeAdapter<MucType> {
  @override
  final int typeId = 29;

  @override
  MucType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MucType.Private;
      case 1:
        return MucType.Public;
      default:
        return MucType.Private;
    }
  }

  @override
  void write(BinaryWriter writer, MucType obj) {
    switch (obj) {
      case MucType.Private:
        writer.writeByte(0);
        break;
      case MucType.Public:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MucTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
