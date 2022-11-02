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
      case 2:
        return SendingStatus.UPLOAD_FILE_COMPLETED;
      case 3:
        return SendingStatus.UPLOAD_FILE_FAIL;
      case 4:
        return SendingStatus.UPLOAD_FILE_IN_PROGRESS;
      case 1:
        return SendingStatus.PENDING;
      default:
        return SendingStatus.UPLOAD_FILE_COMPLETED;
    }
  }

  @override
  void write(BinaryWriter writer, SendingStatus obj) {
    switch (obj) {
      case SendingStatus.UPLOAD_FILE_COMPLETED:
        writer.writeByte(2);
        break;
      case SendingStatus.UPLOAD_FILE_FAIL:
        writer.writeByte(3);
        break;
      case SendingStatus.UPLOAD_FILE_IN_PROGRESS:
        writer.writeByte(4);
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
