import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'call_event.g.dart';

@HiveType(typeId: CALL_EVENT_TRACK_ID)
class CallEvent {
  // DbId
  @HiveField(0)
  int endOfCallTime;

  @HiveField(1)
  int callDuration;

  @HiveField(2)
  CallType callType;

  @HiveField(3)
  CallStatus newStatus;

  @HiveField(4)
  String id;

  CallEvent({
    required this.callDuration,
    required this.endOfCallTime,
    required this.callType,
    required this.newStatus,
    required this.id,
  });
}
