import 'package:we/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'media_type.g.dart';

@HiveType(typeId: MEDIA_TYPE_TRACK_ID)
enum MediaType {
  @HiveField(0)
  IMAGE,
  @HiveField(1)
  VIDEO,
  @HiveField(2)
  FILE,
  @HiveField(3)
  AUDIO,
  @HiveField(4)
  MUSIC,
  @HiveField(5)
  DOCUMENT,
  @HiveField(6)
  LINK,
  @HiveField(7)
  NOT_SET
}
