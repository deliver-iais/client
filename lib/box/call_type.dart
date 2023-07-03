import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'call_type.g.dart';

@HiveType(typeId: CALL_TYPE_TRACK_ID)
enum CallType {
  @HiveField(0)
  AUDIO,
  @HiveField(1)
  VIDEO,
  @HiveField(2)
  GROUP_VIDEO,
  @HiveField(3)
  GROUP_AUDIO,
}
