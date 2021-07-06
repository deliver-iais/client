// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sending_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SendingStatusAdapter extends TypeAdapter<SendingStatus> {
  @override
  final int typeId = 15;

  @override
  SendingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SendingStatus.SENDING_FILE;
      case 1:
        return SendingStatus.PENDING;
      default:
        return SendingStatus.SENDING_FILE;
    }
  }

  @override
  void write(BinaryWriter writer, SendingStatus obj) {
    switch (obj) {
      case SendingStatus.SENDING_FILE:
        writer.writeByte(0);
        break;
      case SendingStatus.PENDING:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
