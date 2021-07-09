import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/sending_status.dart';
import 'package:deliver_flutter/shared/constants.dart';
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
      {this.roomUid,
      this.packetId,
      this.msg,
      this.failed,
      this.status});

  PendingMessage copy(PendingMessage pm) => PendingMessage(
        roomUid: pm.roomUid ?? this.roomUid,
        packetId: pm.packetId ?? this.packetId,
        msg: pm.msg ?? this.msg,
        failed: pm.failed ?? this.failed,
        status: pm.status ?? this.status,
      );

  PendingMessage copyWith(
          {String roomUid,
          String packetId,
          Message msg,
          bool failed,
          int retries,
          SendingStatus status}) =>
      PendingMessage(
        roomUid: roomUid ?? this.roomUid,
        packetId: packetId ?? this.packetId,
        msg: msg ?? this.msg,
        failed: failed ?? this.failed,
        status: status ?? this.status,
      );
}
