import 'dart:async';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class MessageDao extends DBManager {
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

  //Pending Edited Message

  Future<PendingMessage?> getPendingEditedMessage(String roomUid, int? index);

  Future<List<PendingMessage>> getAllPendingEditedMessages();

  Future<void> deletePendingEditedMessage(String roomUid, int? index);

  Future<void> savePendingEditedMessage(PendingMessage pm);

  Stream<List<PendingMessage>> watchPendingEditedMessages(String roomUid);

  Stream<PendingMessage?> watchPendingEditedMessage(String roomUid, int? index);
}

class MessageDaoImpl extends MessageDao {
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

  static String _keyPendingEdited() => "pending-edited";

  Future<BoxPlus<Message>> _openMessages(String uid) async {
    try {
      super.open(_keyMessages(uid.replaceAll(":", "-")), MESSAGE_TABLE_NAME);
      return gen(Hive.openBox<Message>(_keyMessages(uid.replaceAll(":", "-"))));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyMessages(uid.replaceAll(":", "-")));
      return gen(Hive.openBox<Message>(_keyMessages(uid.replaceAll(":", "-"))));
    }
  }

  Future<BoxPlus<PendingMessage>> _openPendingMessages() async {
    try {
      super.open(_keyPending(), PENDING_MESSAGE_TABLE_NAME);
      return gen(Hive.openBox<PendingMessage>(_keyPending()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyPending());
      return gen(Hive.openBox<PendingMessage>(_keyPending()));
    }
  }

  static String _generatePendingEditedMessageKey(
    String roomUid,
    int index,
  ) {
    return "$roomUid-$index";
  }

  Future<BoxPlus<PendingMessage>> _openPendingEditedMessages() async {
    try {
      super.open(_keyPendingEdited(), EDIT_PENDING_TABLE_NAME);
      return gen(Hive.openBox<PendingMessage>(_keyPendingEdited()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyPendingEdited());
      return gen(Hive.openBox<PendingMessage>(_keyPendingEdited()));
    }
  }

  @override
  Future<void> deletePendingEditedMessage(String roomUid, int? index) async {
    if (index != null) {
      final box = await _openPendingEditedMessages();
      return box.delete(_generatePendingEditedMessageKey(roomUid, index));
    }
  }

  @override
  Future<PendingMessage?> getPendingEditedMessage(
    String roomUid,
    int? index,
  ) async {
    if (index != null) {
      final box = await _openPendingEditedMessages();
      return box.get(_generatePendingEditedMessageKey(roomUid, index));
    }
    return null;
  }

  @override
  Future<void> savePendingEditedMessage(PendingMessage pm) async {
    final box = await _openPendingEditedMessages();

    return box.put(
      _generatePendingEditedMessageKey(pm.roomUid, pm.msg.id ?? 0),
      pm,
    );
  }

  @override
  Future<List<PendingMessage>> getAllPendingEditedMessages() async {
    final box = await _openPendingEditedMessages();
    return box.values.toList();
  }

  @override
  Stream<List<PendingMessage>> watchPendingEditedMessages(
    String roomUid,
  ) async* {
    final box = await _openPendingEditedMessages();

    yield box.values.where((element) => element.roomUid == roomUid).toList();

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
              .toList(),
        );
  }

  @override
  Stream<PendingMessage?> watchPendingEditedMessage(
    String roomUid,
    int? index,
  ) async* {
    final box = await _openPendingEditedMessages();

    yield box.get(_generatePendingEditedMessageKey(roomUid, index ?? 0));

    yield* box.watch().map(
          (event) =>
              box.get(_generatePendingEditedMessageKey(roomUid, index ?? 0)),
        );
  }
}
