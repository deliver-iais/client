import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

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
  DECLINED,
}
