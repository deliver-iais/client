// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 24;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      countryCode: fields[0] as String?,
      nationalNumber: fields[1] as String?,
      username: fields[2] as String?,
      firstname: fields[3] as String?,
      lastname: fields[4] as String?,
      passwordProtected: fields[5] as bool?,
      email: fields[6] as String?,
      description: fields[7] as String?,
      emailVerified: fields[8] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.countryCode)
      ..writeByte(1)
      ..write(obj.nationalNumber)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.firstname)
      ..writeByte(4)
      ..write(obj.lastname)
      ..writeByte(5)
      ..write(obj.passwordProtected)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.emailVerified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
