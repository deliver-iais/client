import 'dart:async';

import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class MessageDao {
  Future<void> saveMessage(Message message);

  Future<void> deleteMessage(Message message);

  Future<Message?> getMessage(String roomUid, int id);

  Future<List<Message>> getMessagePage(
    String roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  });

  // Pending Messages
  Future<List<PendingMessage>> getPendingMessages(String roomUid);

  Stream<List<PendingMessage>> watchPendingMessages(String roomUid);

  Future<PendingMessage?> getPendingMessage(String packetId);

  Stream<PendingMessage?> watchPendingMessage(String packetId);

  Future<List<PendingMessage>> getAllPendingMessages();

  Future<void> deletePendingMessage(String packetId);

  Future<void> savePendingMessage(PendingMessage pm);
}

class MessageDaoImpl implements MessageDao {
  @override
  Future<void> deleteMessage(Message message) async {
    final box = await _openMessages(message.roomUid);

    return box.delete(message.id);
  }

  @override
  Future<void> deletePendingMessage(String packetId) async {
    final box = await _openPendingMessages();

    return box.delete(packetId);
  }

  @override
  Future<Message?> getMessage(String roomUid, int id) async {
    final box = await _openMessages(roomUid);

    return box.get(id);
  }

  @override
  Future<List<PendingMessage>> getAllPendingMessages() async {
    final box = await _openPendingMessages();

    return box.values.toList();
  }

  @override
  Future<List<Message>> getMessagePage(
    String roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  }) async {
    final box = await _openMessages(roomUid);

    return Iterable<int>.generate(pageSize)
        .map((e) => page * pageSize + e)
        .map((e) => box.get(e))
        .where((element) => element != null)
        .map((element) => element!)
        .toList();
  }

  @override
  Future<List<PendingMessage>> getPendingMessages(String roomUid) async {
    final box = await _openPendingMessages();

    return box.values.where((element) => element.roomUid == roomUid).toList();
  }

  @override
  Stream<List<PendingMessage>> watchPendingMessages(String roomUid) async* {
    final box = await _openPendingMessages();

    yield box.values
        .where((element) => element.roomUid == roomUid)
        .toList()
        .reversed
        .toList();

    yield* box
        .watch()
        .where(
          (event) =>
              event.deleted ||
              (event.value as PendingMessage).roomUid == roomUid,
        )
        .map(
          (event) => box.values
              .where((element) => element.roomUid == roomUid)
              .toList()
              .reversed
              .toList(),
        );
  }

  @override
  Future<PendingMessage?> getPendingMessage(String packetId) async {
    final box = await _openPendingMessages();

    return box.get(packetId);
  }

  @override
  Stream<PendingMessage?> watchPendingMessage(String packetId) async* {
    final box = await _openPendingMessages();

    yield box.get(packetId);

    yield* box.watch().map((event) => box.get(packetId));
  }

  @override
  Future<void> saveMessage(Message message) async {
    final box = await _openMessages(message.roomUid);

    return box.put(message.id, message);
  }

  @override
  Future<void> savePendingMessage(PendingMessage pm) async {
    final box = await _openPendingMessages();

    return box.put(pm.packetId, pm);
  }

  static String _keyMessages(String uid) => "message-$uid";

  static String _keyPending() => "pending";

  static Future<BoxPlus<Message>> _openMessages(String uid) async {
    try {
      unawaited(BoxInfo.addBox(_keyMessages(uid.replaceAll(":", "-"))));
      return gen(Hive.openBox<Message>(_keyMessages(uid.replaceAll(":", "-"))));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyMessages(uid.replaceAll(":", "-")));
      return gen(Hive.openBox<Message>(_keyMessages(uid.replaceAll(":", "-"))));
    }
  }

  static Future<BoxPlus<PendingMessage>> _openPendingMessages() async {
    try {
      unawaited(BoxInfo.addBox(_keyPending()));
      return gen(Hive.openBox<PendingMessage>(_keyPending()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyPending());
      return gen(Hive.openBox<PendingMessage>(_keyPending()));
    }
  }
}
