import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/adapters.dart';

part 'call_data_usage.g.dart';

@HiveType(typeId: CALL_DATE_USAGE_TRACK_ID)
class CallDataUsage {
  @HiveField(0)
  String callId;

  @HiveField(1)
  int byteSend;

  @HiveField(2)
  int byteReceived;

  CallDataUsage({
    required this.callId,
    required this.byteSend,
    required this.byteReceived,
  });
}
