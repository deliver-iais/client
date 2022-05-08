import 'package:hive/hive.dart';

import '../shared/constants.dart';

// ignore_for_file: constant_identifier_names
part 'call_status.g.dart';

@HiveType(typeId: CALL_STATUS_TRACK_ID)
enum CallStatus {
  @HiveField(0)
  CREATED,
  @HiveField(1)
  IS_RINGING,
  @HiveField(2)
  BUSY,
  @HiveField(3)
  ENDED,
  @HiveField(4)
  JOINED,
  @HiveField(5)
  INVITE,
  @HiveField(6)
  KICK,
  @HiveField(7)
  LEFT,
  @HiveField(8)
  DECLINED,
}
