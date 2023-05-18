

import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'broadcast_message_status_type.g.dart';

@HiveType(typeId: BROADCAST_MESSAGE_STATUS_TYPE_TRACK_ID)
enum BroadcastMessageStatusType {
  @HiveField(0)
  WAITING,

  @HiveField(1)
  SENDING,

  @HiveField(2)
  FAILED,
}
