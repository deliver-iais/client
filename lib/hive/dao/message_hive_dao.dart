import 'dart:async';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/hive/message_hive.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive/hive.dart';

class MessageDaoImpl extends MessageDao {
  @override
  Future<Message?> getMessageById(Uid roomUid, int id) async {
    final box = await _openMessages(roomUid.asString());

    return box.values
        .where((element) => element.id == id)
        .firstOrNull
        ?.fromHive();
  }

  @override
  Future<Message?> getMessageByLocalNetworkId(Uid roomUid, int id) async {
    final box = await _openMessages(roomUid.asString());

    return box.get(id)?.fromHive();
  }

  @override
  Future<Message?> getMessageByPacketId(Uid roomUid, String packetId) async {
    final box = await _openMessages(roomUid.asString());

    return box.values
        .where((element) => element.packetId == packetId)
        .firstOrNull
        ?.fromHive();
  }

  @override
  Future<List<Message>> getMessagePage(
    Uid roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  }) async {
    final box = await _openMessages(roomUid.asString());

    return Iterable<int>.generate(pageSize)
        .map((e) => page * pageSize + e)
        .map((e) => box.get(e))
        .where((element) => element != null)
        .map((element) => element!)
        .map((e) => e.fromHive())
        .toList();
  }

  @override
  Future<void> insertMessage(Message message) async {
    final box = await _openMessages(message.roomUid.asString());

    return box.put(message.localNetworkMessageId, message.toHive());
  }

  static String _keyMessages(String uid) =>
      "message-${uid.convertUidStringToDaoKey()}";

  Future<BoxPlus<MessageHive>> _openMessages(String uid) async {
    try {
      DBManager.open(
        _keyMessages(uid.replaceAll(":", "-")),
        TableInfo.MESSAGE_TABLE_NAME,
      );
      return gen(
        Hive.openBox<MessageHive>(_keyMessages(uid.replaceAll(":", "-"))),
      );
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyMessages(uid.replaceAll(":", "-")));
      return gen(
        Hive.openBox<MessageHive>(_keyMessages(uid.replaceAll(":", "-"))),
      );
    }
  }

  @override
  Future<void> updateMessage(Message message) => insertMessage(message);

  @override
  Future<List<Message>> searchMessages(Uid roomUid, String keyword) async {
    final box = await _openMessages(roomUid.asString());
    final messages = box.values
        .where((msgHive) {
          if (msgHive.roomUid == roomUid.asString()) {
            if (msgHive.type == MessageType.TEXT) {
              return msgHive.json.toText().text.contains(keyword);
            } else if (msgHive.type == MessageType.FILE) {
              return msgHive.json.toFile().caption.contains(keyword);
            }
          }
          return false;
        })
        .map((msgHive) => msgHive.fromHive())
        .toList();
    return messages.reversed.toList();
  }

  @override
  Future<void> saveMessages(List<Message> messages) async {
    for (final element in messages) {
      await insertMessage(element);
    }
  }

  @override
  Future<List<Message>> getLocalMessages(Uid roomUid) {
    // TODO: implement getLocalMessages
    throw UnimplementedError();
  }
}
