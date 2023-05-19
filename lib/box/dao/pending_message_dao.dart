import 'dart:async';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class PendingMessageDao {
  Future<List<PendingMessage>> getPendingMessages(String roomUid);

  Stream<List<PendingMessage>> watchPendingMessages(Uid roomUid);

  Future<PendingMessage?> getPendingMessage(String packetId);

  Future<List<PendingMessage>> getAllPendingMessages();

  Future<void> deletePendingMessage(String packetId);

  Future<void> deleteAllPendingMessageForRoom(Uid roomUid);

  Future<void> savePendingMessage(PendingMessage pm);

  Future<PendingMessage?> getPendingEditedMessage(Uid roomUid, int? index);

  Future<List<PendingMessage>> getAllPendingEditedMessages();

  Future<void> deletePendingEditedMessage(Uid roomUid, int? index);

  Stream<List<PendingMessage>> watchPendingEditedMessages(Uid roomUid);
}
