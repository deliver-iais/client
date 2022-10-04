// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 12;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.TEXT;
      case 1:
        return MessageType.FILE;
      case 2:
        return MessageType.STICKER;
      case 3:
        return MessageType.LOCATION;
      case 4:
        return MessageType.LIVE_LOCATION;
      case 5:
        return MessageType.POLL;
      case 6:
        return MessageType.FORM;
      case 7:
        return MessageType.PERSISTENT_EVENT;
      case 8:
        return MessageType.NOT_SET;
      case 9:
        return MessageType.BUTTONS;
      case 10:
        return MessageType.SHARE_UID;
      case 11:
        return MessageType.FORM_RESULT;
      case 12:
        return MessageType.SHARE_PRIVATE_DATA_REQUEST;
      case 13:
        return MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE;
      case 14:
        return MessageType.CALL;
      case 15:
        return MessageType.TABLE;
      case 16:
        return MessageType.TRANSACTION;
      case 17:
        return MessageType.PAYMENT_INFORMATION;
      default:
        return MessageType.TEXT;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.TEXT:
        writer.writeByte(0);
        break;
      case MessageType.FILE:
        writer.writeByte(1);
        break;
      case MessageType.STICKER:
        writer.writeByte(2);
        break;
      case MessageType.LOCATION:
        writer.writeByte(3);
        break;
      case MessageType.LIVE_LOCATION:
        writer.writeByte(4);
        break;
      case MessageType.POLL:
        writer.writeByte(5);
        break;
      case MessageType.FORM:
        writer.writeByte(6);
        break;
      case MessageType.PERSISTENT_EVENT:
        writer.writeByte(7);
        break;
      case MessageType.NOT_SET:
        writer.writeByte(8);
        break;
      case MessageType.BUTTONS:
        writer.writeByte(9);
        break;
      case MessageType.SHARE_UID:
        writer.writeByte(10);
        break;
      case MessageType.FORM_RESULT:
        writer.writeByte(11);
        break;
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        writer.writeByte(12);
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        writer.writeByte(13);
        break;
      case MessageType.CALL:
        writer.writeByte(14);
        break;
      case MessageType.TABLE:
        writer.writeByte(15);
        break;
      case MessageType.TRANSACTION:
        writer.writeByte(16);
        break;
      case MessageType.PAYMENT_INFORMATION:
        writer.writeByte(17);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
