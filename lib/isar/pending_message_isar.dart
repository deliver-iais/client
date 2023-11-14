import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'pending_message_isar.g.dart';

@collection
class PendingMessageIsar {
  Id get id => fastHash(packetId);

  final String roomUid;

  final String packetId;

  final String msg;

  final bool failed;

  final int messageId;

  final bool isLocalMessage;

  @enumerated
  SendingStatus status;

  PendingMessageIsar({
    required this.roomUid,
    required this.packetId,
    required this.msg,
    required this.status,
    required this.messageId,
    this.failed = false,
    this.isLocalMessage = false,
  });

  PendingMessage fromIsar() => PendingMessage(
        roomUid: roomUid.asUid(),
        packetId: packetId,
        failed: failed,
        status: status,
        isLocalMessage: isLocalMessage,
        msg: getMessageFromJson(msg),
      );
}

extension PendingMessageIsarMapper on PendingMessage {
  PendingMessageIsar toIsar() => PendingMessageIsar(
        roomUid: roomUid.asString(),
        packetId: packetId,
        failed: failed,
        status: status,
      isLocalMessage:isLocalMessage,
        msg: messageToJson(msg),
        messageId: msg.id ?? 0,
      );
}
