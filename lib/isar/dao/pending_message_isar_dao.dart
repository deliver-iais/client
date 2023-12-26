import 'dart:async';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/pending_message_isar.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class PendingMessageDaoImpl with SortPending implements PendingMessageDao {
  Future<Isar> _openPendingMessageIsar() => IsarManager.open();

  @override
  Future<void> deletePendingMessage(String packetId) async {
    try {
      final box = await _openPendingMessageIsar();
      return box
          .writeTxn(() => box.pendingMessageIsars.delete(fastHash(packetId)));
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<List<PendingMessage>> getAllPendingMessages() async {
    final box = await _openPendingMessageIsar();

    return sort(
      (await box.pendingMessageIsars
              .filter()
              .messageIdLessThan(1)
              .build()
              .findAll())
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

      return sort(
        (await box.pendingMessageIsars
                .filter()
                .messageIdLessThan(1)
                .and()
                .roomUidEqualTo(roomUid)
                .findAll())
            .map((e) => e.fromIsar())
            .toList(),
      );
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

    yield sort((await query.findAll()).map((e) => e.fromIsar()).toList());

    yield* query
        .watch()
        .map((event) => sort(event.map((e) => e.fromIsar()).toList()));
  }

  @override
  Future<PendingMessage?> getPendingMessage(String packetId) async {
    try {
      final box = await _openPendingMessageIsar();

      return (await box.pendingMessageIsars.get(fastHash(packetId)))
          ?.fromIsar();
    } catch (e) {}
  }

  @override
  Future<void> savePendingMessage(PendingMessage pm) async {
    final box = await _openPendingMessageIsar();
    return box.writeTxn(() async {
      try {
        await box.pendingMessageIsars.put(pm.toIsar());
      } catch (e) {
        // savePendingMessage(pm);
      }
    });
  }

  @override
  Future<void> deletePendingEditedMessage(Uid roomUid, int? index) async {
    if (index == null) {
      return;
    }

    final box = await _openPendingMessageIsar();

    return box.writeTxn(() async {
      await box.pendingMessageIsars
          .filter()
          .roomUidEqualTo(roomUid.asString())
          .messageIdEqualTo(index)
          .build()
          .deleteFirst();
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

    return (await box.pendingMessageIsars
            .filter()
            .roomUidEqualTo(roomUid.asString())
            .messageIdEqualTo(index)
            .findFirst())
        ?.fromIsar();
  }

  @override
  Future<List<PendingMessage>> getAllPendingEditedMessages() async {
    final box = await _openPendingMessageIsar();

    return (await box.pendingMessageIsars
            .filter()
            .messageIdGreaterThan(0)
            .build()
            .findAll())
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

    yield (await query.findAll()).map((e) => e.fromIsar()).toList();

    yield* query
        .watch()
        .map((event) => event.map((e) => e.fromIsar()).toList());
  }

  @override
  Future<void> deleteAllPendingMessageForRoom(Uid roomUid) async {
    final box = await _openPendingMessageIsar();

    return box.writeTxn(() async {
      await box.pendingMessageIsars
          .filter()
          .roomUidEqualTo(roomUid.asString())
          .build()
          .deleteAll();
    });
  }
}
