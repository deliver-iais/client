// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactHiveAdapter extends TypeAdapter<ContactHive> {
  @override
  final int typeId = 3;

  @override
  ContactHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactHive(
      countryCode: fields[0] as int,
      nationalNumber: fields[1] as int,
      uid: fields[2] as String?,
      firstName: fields[3] as String?,
      lastName: fields[4] as String?,
      description: fields[5] as String?,
      updateTime: fields[6] as int?,
      syncHash: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ContactHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.countryCode)
      ..writeByte(1)
      ..write(obj.nationalNumber)
      ..writeByte(2)
      ..write(obj.uid)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.updateTime)
      ..writeByte(7)
      ..write(obj.syncHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
