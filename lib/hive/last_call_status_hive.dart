import 'package:deliver/box/last_call_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'last_call_status_hive.g.dart';

@HiveType(typeId: LAST_CALL_STATUS_TRACK_ID)
class LastCallStatusHive {
  @HiveField(0)
  String id;

  @HiveField(1)
  String callId;

  @HiveField(2)
  String roomUid;

  @HiveField(3)
  int expireTime;

  LastCallStatusHive({
    required this.id,
    required this.callId,
    required this.roomUid,
    required this.expireTime,
  });

  LastCallStatusHive copyWith({
    String? id,
    String? callId,
    String? roomUid,
    int? expireTime,
  }) {
    return LastCallStatusHive(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      roomUid: roomUid ?? this.roomUid,
      expireTime: expireTime ?? this.expireTime,
    );
  }

  LastCallStatus fromHive() => LastCallStatus(
        id: int.parse(id),
        callId: callId,
        roomUid: roomUid,
        expireTime: expireTime,
      );
}

extension LastCallStatusHiveMapper on LastCallStatus {
  LastCallStatusHive toHive() => LastCallStatusHive(
        id: id.toString(),
        callId: callId,
        roomUid: roomUid,
        expireTime: expireTime,
      );
}
