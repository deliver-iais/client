import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'sending_status.g.dart';

@HiveType(typeId: SENDING_STATUS_TRACK_ID)
enum SendingStatus {
  @HiveField(0)
  SENDING_FILE,

  @HiveField(1)
  PENDING
}
