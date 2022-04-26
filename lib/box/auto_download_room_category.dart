import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'auto_download_room_category.g.dart';

@HiveType(typeId: AUTO_DOWNLOAD_ROOM_CATEGORY_TRACK_ID)
enum AutoDownloadRoomCategory {
  @HiveField(0)
  IN_PRIVATE_CHATS,
  @HiveField(1)
  IN_GROUP,
  @HiveField(2)
  IN_CHANNEL,
}
