import 'dart:async';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/pending_message_isar.dart';
import 'package:isar/isar.dart';

class PendingMessageDaoImpl extends PendingMessageDao {
  Future<Isar> _openPendingMessageIsar() => IsarManager.open();

  @override
  Future<void> deletePendingMessage(String packetId) async {
    final box = await _openPendingMessageIsar();

    return box.writeTxnSync(() {
      box.pendingMessageIsars.deleteSync(fastHash(packetId));
    });
  }

  @override
  Future<List<PendingMessage>> getAllPendingMessages() async {
    final box = await _openPendingMessageIsar();

    return box.pendingMessageIsars
        .filter()
        .messageIdLessThan(1)
        .build()
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<List<PendingMessage>> getPendingMessages(
    String roomUid,
  ) async {
    final box = await _openPendingMessageIsar();

    return box.pendingMessageIsars
        .filter()
        .messageIdLessThan(1)
        .roomUidEqualTo(roomUid)
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Stream<List<PendingMessage>> watchPendingMessages(
    String roomUid,
  ) async* {
    final box = await _openPendingMessageIsar();

    final query = box.pendingMessageIsars
        .filter()
        .messageIdLessThan(1)
        .roomUidEqualTo(roomUid)
        .build();

    yield query.findAllSync().map((e) => e.fromIsar()).toList();

    yield* query
        .watch()
        .map((event) => event.map((e) => e.fromIsar()).toList());
  }

  @override
  Future<PendingMessage?> getPendingMessage(String packetId) async {
    final box = await _openPendingMessageIsar();

    return box.pendingMessageIsars.getSync(fastHash(packetId))?.fromIsar();
  }

  @override
  Future<void> savePendingMessage(PendingMessage pm) async {
    final box = await _openPendingMessageIsar();
    return box.writeTxnSync(() {
      box.pendingMessageIsars.putSync(pm.toIsar());
    });
  }

  @override
  Future<void> deletePendingEditedMessage(String roomUid, int? index) async {
    if (index == null) {
      return;
    }

    final box = await _openPendingMessageIsar();

    return box.writeTxnSync(() {
      box.pendingMessageIsars
          .filter()
          .roomUidEqualTo(roomUid)
          .messageIdEqualTo(index)
          .build()
          .deleteFirstSync();
    });
  }

  @override
  Future<PendingMessage?> getPendingEditedMessage(
    String roomUid,
    int? index,
  ) async {
    if (index == null) {
      return null;
    }

    final box = await _openPendingMessageIsar();

    return box.pendingMessageIsars
        .filter()
        .roomUidEqualTo(roomUid)
        .messageIdEqualTo(index)
        .findFirstSync()
        ?.fromIsar();
  }

  @override
  Future<List<PendingMessage>> getAllPendingEditedMessages() async {
    final box = await _openPendingMessageIsar();

    return box.pendingMessageIsars
        .filter()
        .messageIdGreaterThan(0)
        .build()
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Stream<List<PendingMessage>> watchPendingEditedMessages(
    String roomUid,
  ) async* {
    final box = await _openPendingMessageIsar();

    final query = box.pendingMessageIsars
        .filter()
        .messageIdGreaterThan(0)
        .roomUidEqualTo(roomUid)
        .build();

    yield query.findAllSync().map((e) => e.fromIsar()).toList();

    yield* query
        .watch()
        .map((event) => event.map((e) => e.fromIsar()).toList());
  }
}
