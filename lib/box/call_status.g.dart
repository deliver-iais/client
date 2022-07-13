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
        return CallStatus.JOINED;
      case 5:
        return CallStatus.INVITE;
      case 6:
        return CallStatus.KICK;
      case 7:
        return CallStatus.LEFT;
      case 8:
        return CallStatus.DECLINED;
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
      case CallStatus.JOINED:
        writer.writeByte(4);
        break;
      case CallStatus.INVITE:
        writer.writeByte(5);
        break;
      case CallStatus.KICK:
        writer.writeByte(6);
        break;
      case CallStatus.LEFT:
        writer.writeByte(7);
        break;
      case CallStatus.DECLINED:
        writer.writeByte(8);
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
