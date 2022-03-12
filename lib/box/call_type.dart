import 'package:hive/hive.dart';

import '../shared/constants.dart';

// ignore_for_file: constant_identifier_names
part 'call_type.g.dart';

@HiveType(typeId: CALL_TYPE_TRACK_ID)
enum CallType {
  @HiveField(0)
  VIDEO,
  @HiveField(1)
  AUDIO,
  @HiveField(2)
  GROUP_VIDEO,
  @HiveField(3)
  GROUP_AUDIO,
}
