import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'meta_type.g.dart';

@HiveType(typeId: META_TYPE_TRACK_ID)
enum MetaType {
  @HiveField(0)
  MEDIA,
  @HiveField(1)
  FILE,
  @HiveField(2)
  AUDIO,
  @HiveField(3)
  MUSIC,
  @HiveField(4)
  CALL,
  @HiveField(5)
  LINK,
  @HiveField(6)
  NOT_SET
}
