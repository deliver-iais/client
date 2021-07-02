// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MucRoleAdapter extends TypeAdapter<MucRole> {
  @override
  final int typeId = 9;

  @override
  MucRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MucRole.NONE;
      case 1:
        return MucRole.MEMBER;
      case 2:
        return MucRole.ADMIN;
      case 3:
        return MucRole.OWNER;
      default:
        return MucRole.NONE;
    }
  }

  @override
  void write(BinaryWriter writer, MucRole obj) {
    switch (obj) {
      case MucRole.NONE:
        writer.writeByte(0);
        break;
      case MucRole.MEMBER:
        writer.writeByte(1);
        break;
      case MucRole.ADMIN:
        writer.writeByte(2);
        break;
      case MucRole.OWNER:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MucRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
