import 'package:deliver/box/media_type.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'media.g.dart';

@HiveType(typeId: MEDIA_TRACK_ID)
class Media {
  // DbId
  @HiveField(0)
  int createdOn;

  @HiveField(1)
  String createdBy;

  @HiveField(2)
  String json;

  @HiveField(3)
  String roomId;

  @HiveField(4)
  int messageId;

  @HiveField(5)
  MediaType type;

  Media(
      {required this.createdOn,
      required this.json,
      required this.roomId,
      required this.messageId,
      required this.type,
      required this.createdBy});
}
