import 'package:deliver/box/last_call_status.dart';
import 'package:isar/isar.dart';

part 'last_call_status_isar.g.dart';

@collection
class LastCallStatusIsar {
  Id? id;

  String callId;

  String roomUid;

  int expireTime;

  LastCallStatusIsar({
    this.id,
    required this.callId,
    required this.roomUid,
    required this.expireTime,
  });

  LastCallStatus fromIsar() => LastCallStatus(
        id: id!,
        callId: callId,
        roomUid: roomUid,
        expireTime: expireTime,
      );
}

extension LastCallStatusIsarMapper on LastCallStatus {
  LastCallStatusIsar toIsar() => LastCallStatusIsar(
        id: id,
        callId: callId,
        roomUid: roomUid,
        expireTime: expireTime,
      );
}
