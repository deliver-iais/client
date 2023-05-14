import 'dart:async';
import 'package:deliver/box/pending_message.dart';

abstract class PendingMessageDao {
  Future<List<PendingMessage>> getPendingMessages(String roomUid);

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid);

  Future<PendingMessage?> getPendingMessage(String packetId);

  Future<List<PendingMessage>> getAllPendingMessages();

  Future<void> deletePendingMessage(String packetId);

  Future<void> savePendingMessage(PendingMessage pm);

  Future<PendingMessage?> getPendingEditedMessage(String roomUid, int? index);

  Future<List<PendingMessage>> getAllPendingEditedMessages();

  Future<void> deletePendingEditedMessage(String roomUid, int? index);

  Stream<List<PendingMessage>> watchPendingEditedMessages(String roomUid);
}


