import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:hive/hive.dart';

abstract class MessageDao {
  Future<void> saveMessage(Message message);

  Future<void> deleteMessage(Message message);

  Future<Message> getMessage(String roomUid, int id);

  Future<List<Message>> getMessagePage(String roomUid, int page,
      {int pageSize = 40});

  // Pending Messages
  Future<List<PendingMessage>> getPendingMessages(String roomUid);

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid);

  Future<PendingMessage> getPendingMessage(String packetId);

  Stream<PendingMessage> watchPendingMessage(String packetId);

  Future<List<PendingMessage>> getAllPendingMessages();

  Future<void> deletePendingMessage(String packetId);

  Future<void> savePendingMessage(PendingMessage pm);
}

class MessageDaoImpl implements MessageDao {
  Future<void> deleteMessage(Message message) async {
    var box = await _openMessages(message.roomUid);

    box.delete(message.id);
  }

  Future<void> deletePendingMessage(String packetId) async {
    var box = await _openPending();

    box.delete(packetId);
  }

  Future<Message> getMessage(String roomUid, int id) async {
    var box = await _openMessages(roomUid);

    return box.get(id);
  }

  Future<List<PendingMessage>> getAllPendingMessages() async {
    var box = await _openPending();

    return box.values.toList();
  }

  Future<List<Message>> getMessagePage(String roomUid, int page,
      {int pageSize = 40}) async {
    var box = await _openMessages(roomUid);

    return Iterable<int>.generate(pageSize)
        .map((e) => page * pageSize + e)
        .map((e) => box.get(e))
        .where((element) => element != null)
        .toList();
  }

  Future<List<PendingMessage>> getPendingMessages(String roomUid) async {
    var box = await _openPending();

    return box.values.where((element) => element.roomUid == roomUid).toList();
  }

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid) async* {
    var box = await _openPending();

    yield box.values.where((element) => element.roomUid == roomUid).toList().reversed.toList();

    yield* box
        .watch()
        .where((event) => (event.value as PendingMessage).roomUid == roomUid || event.deleted)
        .map((event) =>
            box.values.where((element) => element.roomUid == roomUid).toList());
  }

  Future<PendingMessage> getPendingMessage(String packetId) async {
    var box = await _openPending();

    return box.get(packetId);
  }

  Stream<PendingMessage> watchPendingMessage(String packetId) async* {
    var box = await _openPending();

    yield box.get(packetId);

    yield* box.watch().map((event) => box.get(packetId));
  }

  Future<void> saveMessage(Message message) async {
    var box = await _openMessages(message.roomUid);

    box.put(message.id, message);
  }

  Future<void> savePendingMessage(PendingMessage pm) async {
    var box = await _openPending();

    box.put(pm.packetId, pm);
  }

  static String _keyMessages(String uid) => "message-$uid";

  static String _keyPending() => "pending";

  static Future<Box<Message>> _openMessages(String uid) =>
      Hive.openBox<Message>(_keyMessages(uid));

  static Future<Box<PendingMessage>> _openPending() =>
      Hive.openBox<PendingMessage>(_keyPending());
}
