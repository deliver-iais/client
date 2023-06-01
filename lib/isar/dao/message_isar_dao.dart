import 'dart:async';

import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/isar/message_isar.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class MessageDaoImpl extends MessageDao {
  @override
  Future<Message?> getMessage(Uid roomUid, int id) async {
    final box = await _openMessageIsar();
    return box.messageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
        .and()
        .idEqualTo(id)
        .findFirstSync()
        ?.fromIsar();
  }

  @override
  Future<List<Message>> getMessagePage(
    Uid roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  }) async {
    final box = await _openMessageIsar();
    return box.messageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
        .and()
        .idBetween(page * pageSize, (page + 1) * pageSize)
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<void> insertMessage(Message message) async {
    final box = await _openMessageIsar();
    box.writeTxnSync(() => box.messageIsars.putSync(message.toIsar()));
  }

  Future<Isar> _openMessageIsar() => IsarManager.open();

  @override
  Future<void> updateMessage(Message message) async {
    final box = await _openMessageIsar();
    final msg = await (box.messageIsars
        .filter()
        .idEqualTo(message.id)
        .and()
        .roomUidEqualTo(message.roomUid.asString())
        .findFirst());

    await box.writeTxn(() async {
      if (msg != null) {
        await box.messageIsars.delete(msg.dbId);
      }
      unawaited(box.messageIsars.put(message.toIsar()));
    });
  }
}
