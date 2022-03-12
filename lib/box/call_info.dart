import 'package:deliver/box/call_event.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'call_info.g.dart';

@HiveType(typeId: CALL_INFO_TRACK_ID)
class CallInfo {
  // DbId
  @HiveField(0)
  String from;

  @HiveField(1)
  String to;

  @HiveField(2)
  CallEvent callEvent;

  CallInfo({
    required this.callEvent,
    required this.from,
    required this.to,
  });
}
