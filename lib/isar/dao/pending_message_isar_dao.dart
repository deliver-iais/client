import 'dart:async';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/pending_message_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class PendingMessageDaoImpl with SortPending implements PendingMessageDao {
  Future<Isar> _openPendingMessageIsar() => IsarManager.open();

  @override
  Future<void> deletePendingMessage(String packetId) async {
    try {
      final box = await _openPendingMessageIsar();
      return box.writeTxnSync(() {
        box.pendingMessageIsars.deleteSync(fastHash(packetId));
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<List<PendingMessage>> getAllPendingMessages() async {
    final box = await _openPendingMessageIsar();

    return sort(
      box.pendingMessageIsars
          .filter()
          .messageIdLessThan(1)
          .build()
          .findAllSync()
          .map((e) => e.fromIsar())
          .toList(),
    );
  }

  @override
  Future<List<PendingMessage>> getPendingMessages(
    String roomUid,
  ) async {
    try {
      final box = await _openPendingMessageIsar();

      return sort(box.pendingMessageIsars
          .filter()
          .messageIdLessThan(1)
          .and()
          .roomUidEqualTo(roomUid)
          .findAllSync()
          .map((e) => e.fromIsar())
          .toList(),);
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<PendingMessage>> watchPendingMessages(
    Uid roomUid,
  ) async* {
    final box = await _openPendingMessageIsar();

    final query = box.pendingMessageIsars
        .filter()
        .messageIdLessThan(1)
        .roomUidEqualTo(roomUid.asString())
        .build();

    yield sort(query.findAllSync().map((e) => e.fromIsar()).toList());

    yield* query
        .watch()
        .map((event) => sort(event.map((e) => e.fromIsar()).toList()));
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
  Future<void> deletePendingEditedMessage(Uid roomUid, int? index) async {
    if (index == null) {
      return;
    }

    final box = await _openPendingMessageIsar();

    return box.writeTxnSync(() {
      box.pendingMessageIsars
          .filter()
          .roomUidEqualTo(roomUid.asString())
          .messageIdEqualTo(index)
          .build()
          .deleteFirstSync();
    });
  }

  @override
  Future<PendingMessage?> getPendingEditedMessage(
    Uid roomUid,
    int? index,
  ) async {
    if (index == null) {
      return null;
    }

    final box = await _openPendingMessageIsar();

    return box.pendingMessageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
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
    Uid roomUid,
  ) async* {
    final box = await _openPendingMessageIsar();

    final query = box.pendingMessageIsars
        .filter()
        .messageIdGreaterThan(0)
        .roomUidEqualTo(roomUid.asString())
        .build();

    yield query.findAllSync().map((e) => e.fromIsar()).toList();

    yield* query
        .watch()
        .map((event) => event.map((e) => e.fromIsar()).toList());
  }

  @override
  Future<void> deleteAllPendingMessageForRoom(Uid roomUid) async {
    final box = await _openPendingMessageIsar();

    return box.writeTxnSync(() {
      box.pendingMessageIsars
          .filter()
          .roomUidEqualTo(roomUid.asString())
          .build()
          .deleteAllSync();
    });
  }
}
