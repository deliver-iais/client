import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'pending_message_hive.g.dart';

@HiveType(typeId: PENDING_MESSAGE_TRACK_ID)
class PendingMessageHive {
  @HiveField(0)
  final String roomUid;
  @HiveField(1)
  final String packetId;
  @HiveField(2)
  final String msg;
  @HiveField(3)
  final bool failed;
  @HiveField(4)
  final int messageId;
  @HiveField(5)
  SendingStatus status;

  PendingMessageHive({
    required this.roomUid,
    required this.packetId,
    required this.msg,
    required this.failed,
    required this.messageId,
    required this.status,
  });

  PendingMessage fromHive() => PendingMessage(
        roomUid: roomUid.asUid(),
        packetId: packetId,
        failed: failed,
        status: status,
        msg: getMessageFromJson(msg),
      );
}

extension PendingMessageHiveMapper on PendingMessage {
  PendingMessageHive toHive() => PendingMessageHive(
        roomUid: roomUid.asString(),
        packetId: packetId,
        failed: failed,
        status: status,
        msg: msg.toJson(),
        messageId: msg.id ?? 0,
      );
}
