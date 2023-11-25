import 'dart:async';

import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/isar/message_isar.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class MessageDaoImpl extends MessageDao {
  @override
  Future<Message?> getMessageById(Uid roomUid, int id) async {
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
  Future<Message?> getMessageByLocalNetworkId(Uid roomUid, int id) async {
    final box = await _openMessageIsar();
    return box.messageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
        .and()
        .localNetworkMessageIdEqualTo(id)
        .findFirstSync()
        ?.fromIsar();
  }

  @override
  Future<Message?> getMessageByPacketId(Uid roomUid, String packetId) async {
    final box = await _openMessageIsar();
    return box.messageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
        .and()
        .packetIdEqualTo(packetId)
        .findFirstSync()
        ?.fromIsar
    (
    );
  }

  @override
  Future<List<Message>> getMessagePage(Uid roomUid,
      int page, {
        int pageSize = PAGE_SIZE,
      }) async {
    final box = await _openMessageIsar();
    return box.messageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
        .and()
        .localNetworkMessageIdBetween(page * pageSize, (page + 1) * pageSize)
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<void> insertMessage(Message message) async {
    try{
      final box = await _openMessageIsar();
      await box.writeTxn(() => box.messageIsars.put(message.toIsar()));
    } catch(e) {
      print(e);
    }
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

    await box.writeTxnSync(() async {
      if (msg != null) {
        box.messageIsars.deleteSync(msg.dbId);
      }
      box.messageIsars.putSync(message.toIsar());
    });
  }

  @override
  Future<List<Message>> searchMessages(Uid roomUid, String keyword) async {
    final box = await _openMessageIsar();

    final messages = box.messageIsars
        .filter()
        .roomUidEqualTo(roomUid.asString())
        .group((q) =>
        q.typeEqualTo(MessageType.TEXT).or().typeEqualTo(MessageType.FILE))
        .and()
        .jsonContains(keyword)
        .findAllSync()
        .map((e) => e.fromIsar())
        .where((msg) {
      return isMessageContainKeyword(msg, keyword);
    }).toList();

    return messages.reversed.toList();
  }
}
