// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_call_info_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentCallInfoHiveAdapter extends TypeAdapter<CurrentCallInfoHive> {
  @override
  final int typeId = 27;

  @override
  CurrentCallInfoHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentCallInfoHive(
      id: fields[0] as String,
      callEvent: fields[3] as String,
      from: fields[1] as String,
      to: fields[2] as String,
      expireTime: fields[6] as int,
      notificationSelected: fields[7] as bool,
      isAccepted: fields[8] as bool,
      offerBody: fields[4] as String,
      offerCandidate: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentCallInfoHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.to)
      ..writeByte(3)
      ..write(obj.callEvent)
      ..writeByte(4)
      ..write(obj.offerBody)
      ..writeByte(5)
      ..write(obj.offerCandidate)
      ..writeByte(6)
      ..write(obj.expireTime)
      ..writeByte(7)
      ..write(obj.notificationSelected)
      ..writeByte(8)
      ..write(obj.isAccepted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentCallInfoHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
