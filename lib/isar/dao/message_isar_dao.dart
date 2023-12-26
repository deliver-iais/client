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
import 'package:logger/logger.dart';

class MessageDaoImpl extends MessageDao {
  final _logger = Logger();

  @override
  Future<Message?> getMessageById(Uid roomUid, int id) async {
    final box = await _openMessageIsar();
    return (await box.messageIsars
            .filter()
            .roomUidEqualTo(roomUid.asString())
            .and()
            .idEqualTo(id)
            .findFirst())
        ?.fromIsar();
  }

  @override
  Future<Message?> getMessageByLocalNetworkId(Uid roomUid, int id) async {
    final box = await _openMessageIsar();
    return (await box.messageIsars
            .filter()
            .roomUidEqualTo(roomUid.asString())
            .and()
            .localNetworkMessageIdEqualTo(id)
            .findFirst())
        ?.fromIsar();
  }

  @override
  Future<Message?> getMessageByPacketId(Uid roomUid, String packetId) async {
    final box = await _openMessageIsar();
    return (await box.messageIsars
            .filter()
            .roomUidEqualTo(roomUid.asString())
            .and()
            .packetIdEqualTo(packetId)
            .findFirst())
        ?.fromIsar();
  }

  @override
  Future<List<Message>> getMessagePage(
    Uid roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  }) async {
    final box = await _openMessageIsar();
    return (await box.messageIsars
            .filter()
            .roomUidEqualTo(roomUid.asString())
            .and()
            .localNetworkMessageIdBetween(
              page * pageSize,
              (page + 1) * pageSize,
            )
            .findAll())
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<void> insertMessage(Message message) async {
    try {
      final box = await _openMessageIsar();
      await box.writeTxn(() => box.messageIsars.put(message.toIsar()));
    } catch (e) {
      _logger.e(e);
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

    await box.writeTxn(() async {
      if (msg != null) {
        await box.messageIsars.delete(msg.dbId);
      }
      await box.messageIsars.put(message.toIsar());
    });
  }

  @override
  Future<List<Message>> searchMessages(Uid roomUid, String keyword) async {
    final box = await _openMessageIsar();

    final messages = (await box.messageIsars
            .filter()
            .roomUidEqualTo(roomUid.asString())
            .group(
              (q) => q
                  .typeEqualTo(MessageType.TEXT)
                  .or()
                  .typeEqualTo(MessageType.FILE),
            )
            .and()
            .jsonContains(keyword)
            .findAll())
        .map((e) => e.fromIsar())
        .where((msg) {
      return isMessageContainKeyword(msg, keyword);
    }).toList();

    return messages.reversed.toList();
  }

  @override
  Future<void> saveMessages(List<Message> messages) async {
    try {
      final box = await _openMessageIsar();
      await box.writeTxn(
        () => box.messageIsars.putAll(messages.map((e) => e.toIsar()).toList()),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<List<Message>> getLocalMessages(Uid roomUid) async {
    try {
      final box = await _openMessageIsar();
      return (await box.messageIsars
              .filter()
              .roomUidEqualTo(roomUid.asString())
              .and()
              .isLocalMessageEqualTo(true)
              .findAll())
          .map((e) => e.fromIsar())
          .toList();
    } catch (e) {
      _logger.e(e);
      return [];
    }
  }
}
