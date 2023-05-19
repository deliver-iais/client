import 'dart:async';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/hive/message_hive.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive/hive.dart';

class MessageDaoImpl extends MessageDao {
  @override
  Future<Message?> getMessage(Uid roomUid, int id) async {
    final box = await _openMessages(roomUid.asString());

    return box.get(id)?.fromHive();
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
  Future<void> saveMessage(Message message) async {
    final box = await _openMessages(message.roomUid.asString());

    return box.put(message.id, message.toHive());
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
}
