import 'package:deliver/box/message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'pending_message.g.dart';

@HiveType(typeId: PENDING_MESSAGE_TRACK_ID)
class PendingMessage {
  @HiveField(0)
  String roomUid;

  @HiveField(1)
  String packetId;

  @HiveField(2)
  Message msg;

  @HiveField(3)
  bool failed;

  @HiveField(5)
  SendingStatus status;

  PendingMessage(
      {required this.roomUid,
      required this.packetId,
      required this.msg,
      this.failed = false,
      required this.status});

  PendingMessage copy(PendingMessage pm) => PendingMessage(
        roomUid: pm.roomUid,
        packetId: pm.packetId,
        msg: pm.msg,
        failed: pm.failed,
        status: pm.status,
      );

  PendingMessage copyWith(
          {String? roomUid,
          String? packetId,
          Message? msg,
          bool? failed,
          int? retries,
          SendingStatus? status}) =>
      PendingMessage(
        roomUid: roomUid ?? this.roomUid,
        packetId: packetId ?? this.packetId,
        msg: msg ?? this.msg,
        failed: failed ?? this.failed,
        status: status ?? this.status,
      );
}
