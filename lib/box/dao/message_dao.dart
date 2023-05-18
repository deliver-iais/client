import 'dart:async';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:hive/hive.dart';

abstract class MessageDao {
  Future<void> saveMessage(Message message);

  Future<void> deleteMessage(Message message);

  Future<Message?> getMessage(String roomUid, int id);

  Future<List<Message>> getMessagePage(
    String roomUid,
    int page, {
    int pageSize = PAGE_SIZE,
  });
}

class MessageDaoImpl extends MessageDao {
  @override
  Future<void> deleteMessage(Message message) async {
    final box = await _openMessages(message.roomUid);

    return box.delete(message.id);
  }

  @override
  Future<Message?> getMessage(String roomUid, int id) async {
    final box = await _openMessages(roomUid);

    return box.get(id);
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
  Future<void> saveMessage(Message message) async {
    final box = await _openMessages(message.roomUid);

    return box.put(message.id, message);
  }

  static String _keyMessages(String uid) => "message-${uid.convertUidStringToDaoKey()}";

  Future<BoxPlus<Message>> _openMessages(String uid) async {
    try {
      DBManager.open(
        _keyMessages(uid),
        TableInfo.MESSAGE_TABLE_NAME,
      );
      return gen(Hive.openBox<Message>(_keyMessages(uid)));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyMessages(uid));
      return gen(Hive.openBox<Message>(_keyMessages(uid)));
    }
  }
}
