import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/hive/pending_message_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PendingMessageDaoImpl with SortPending implements PendingMessageDao {
  String _keyPendingMessage() => "pending_message";

  @override
  Future<void> deletePendingEditedMessage(Uid roomUid, int? index) async {
    if (index != null) {
      final box = await _openPendingMessages();
      return box
          .delete(_generatePendingEditedMessageKey(roomUid.asString(), index));
    }
  }

  @override
  Future<void> deletePendingMessage(String packetId) async {
    final box = await _openPendingMessages();

    return box.delete(packetId);
  }

  @override
  Future<List<PendingMessage>> getAllPendingEditedMessages() async {
    final box = await _openPendingMessages();
    return box.values
        .where((element) => element.messageId > 0)
        .map((e) => e.fromHive())
        .toList();
  }

  @override
  Future<List<PendingMessage>> getAllPendingMessages() async {
    final box = await _openPendingMessages();

    return box.values.map((e) => e.fromHive()).toList();
  }

  @override
  Future<PendingMessage?> getPendingEditedMessage(
    Uid roomUid,
    int? index,
  ) async {
    if (index != null) {
      final box = await _openPendingMessages();
      return box
          .get(_generatePendingEditedMessageKey(roomUid.asString(), index))
          ?.fromHive();
    }
    return null;
  }

  @override
  Future<PendingMessage?> getPendingMessage(String packetId) async {
    final box = await _openPendingMessages();

    return box.get(packetId)?.fromHive();
  }

  @override
  Future<List<PendingMessage>> getPendingMessages(String roomUid) async {
    final box = await _openPendingMessages();

    return box.values
        .where((element) => element.roomUid == roomUid)
        .map((e) => e.fromHive())
        .toList();
  }

  @override
  Future<void> savePendingMessage(PendingMessage pm) async {
    final box = await _openPendingMessages();
    if (pm.msg.id != null) {
      return box.put(
        _generatePendingEditedMessageKey(pm.roomUid.asString(), pm.msg.id!),
        pm.toHive(),
      );
    } else {
      return box.put(pm.packetId, pm.toHive());
    }
  }

  @override
  Stream<List<PendingMessage>> watchPendingEditedMessages(
    Uid roomUid,
  ) async* {
    final box = await _openPendingMessages();

    yield box.values
        .where((element) => element.roomUid == roomUid.asString())
        .map((e) => e.fromHive())
        .toList();

    yield* box
        .watch()
        .where(
          (event) =>
              event.deleted ||
              (event.value as PendingMessageHive).roomUid == roomUid.asString(),
        )
        .map(
          (event) => box.values
              .where((element) => element.roomUid == roomUid.asString())
              .map((e) => e.fromHive())
              .toList(),
        );
  }

  @override
  Stream<List<PendingMessage>> watchPendingMessages(Uid roomUid) async* {
    final box = await _openPendingMessages();

    yield box.values
        .where((element) => element.roomUid == roomUid.asString())
        .map((e) => e.fromHive())
        .toList()
        .reversed
        .toList();

    yield* box
        .watch()
        .where(
          (event) =>
              event.deleted ||
              (event.value as PendingMessageHive).roomUid == roomUid.asString(),
        )
        .map(
          (event) => box.values
              .where((element) => element.roomUid == roomUid.asString())
              .map((e) => e.fromHive())
              .toList()
              .reversed
              .toList(),
        );
  }

  Future<BoxPlus<PendingMessageHive>> _openPendingMessages() async {
    try {
      DBManager.open(
        _keyPendingMessage(),
        TableInfo.PENDING_MESSAGE_TABLE_NAME,
      );
      return gen(Hive.openBox<PendingMessageHive>(_keyPendingMessage()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyPendingMessage());
      return gen(Hive.openBox<PendingMessageHive>(_keyPendingMessage()));
    }
  }

  String _generatePendingEditedMessageKey(String roomUid, int index) =>
      "$roomUid-$index";

  @override
  Future<void> deleteAllPendingMessageForRoom(Uid roomUid) async {
    final box = await _openPendingMessages();
    return box.clear();
  }
}
