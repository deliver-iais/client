// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_download_room_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AutoDownloadRoomCategoryAdapter
    extends TypeAdapter<AutoDownloadRoomCategory> {
  @override
  final int typeId = 25;

  @override
  AutoDownloadRoomCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AutoDownloadRoomCategory.IN_PRIVATE_CHATS;
      case 1:
        return AutoDownloadRoomCategory.IN_GROUP;
      case 2:
        return AutoDownloadRoomCategory.IN_CHANNEL;
      default:
        return AutoDownloadRoomCategory.IN_PRIVATE_CHATS;
    }
  }

  @override
  void write(BinaryWriter writer, AutoDownloadRoomCategory obj) {
    switch (obj) {
      case AutoDownloadRoomCategory.IN_PRIVATE_CHATS:
        writer.writeByte(0);
        break;
      case AutoDownloadRoomCategory.IN_GROUP:
        writer.writeByte(1);
        break;
      case AutoDownloadRoomCategory.IN_CHANNEL:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoDownloadRoomCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
