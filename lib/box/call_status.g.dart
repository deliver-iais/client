// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallStatusAdapter extends TypeAdapter<CallStatus> {
  @override
  final int typeId = 22;

  @override
  CallStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallStatus.CREATED;
      case 1:
        return CallStatus.IS_RINGING;
      case 2:
        return CallStatus.BUSY;
      case 3:
        return CallStatus.ENDED;
      case 4:
        return CallStatus.DECLINED;
      case 5:
        return CallStatus.ACCEPTED;
      default:
        return CallStatus.CREATED;
    }
  }

  @override
  void write(BinaryWriter writer, CallStatus obj) {
    switch (obj) {
      case CallStatus.CREATED:
        writer.writeByte(0);
        break;
      case CallStatus.IS_RINGING:
        writer.writeByte(1);
        break;
      case CallStatus.BUSY:
        writer.writeByte(2);
        break;
      case CallStatus.ENDED:
        writer.writeByte(3);
        break;
      case CallStatus.DECLINED:
        writer.writeByte(4);
        break;
      case CallStatus.ACCEPTED:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
