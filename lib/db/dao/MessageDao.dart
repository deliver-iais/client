import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';
import 'package:rxdart/streams.dart';
import '../Messages.dart';
import '../database.dart';
import 'dart:async';

part 'MessageDao.g.dart';

@UseDao(tables: [Messages])
class MessageDao extends DatabaseAccessor<Database> with _$MessageDaoMixin {
  final Database database;

  MessageDao(this.database) : super(database);

  Stream watchAllMessages() => select(messages).watch();

  Future insertBulk(List<Message> messages) {

  }

  Future<int> insertMessage(Message newMessage) =>
      into(messages).insertOnConflictUpdate(newMessage);

  Future<int> updateMessageId(String roomId, String packetID, int id, int time) {
    (update(messages)
          ..where((t) => t.roomId.equals(roomId) & t.packetId.equals(packetID)))
        .write(
      MessagesCompanion(
        id: Value(id),
        time: Value(DateTime.fromMillisecondsSinceEpoch(time))
      ),
    );
  }

  Future deleteMessage(Message message) => delete(messages).delete(message);

  Future updateMessage(Message updatedMessage) =>
      update(messages).replace(updatedMessage);

  Stream<List<Message>> getByRoomId(String roomId, int lastShowedMessageId) {
    return (select(messages)
          ..orderBy([
            (m) => OrderingTerm(expression: m.time, mode: OrderingMode.desc),
          ])
          ..where((message) => message.roomId.equals(roomId)))
        .watch();
  }

  Stream<Message> getById(int id, String roomId) {
    return (select(messages)
          ..where((m) => m.roomId.equals(roomId) & m.id.equals(id)))
        .watchSingle();
  }

  Future<List<Message>> getPage(String roomId, int page,
      {int pageSize = 50}) async {
    return (select(messages)
          ..where((m) =>
              m.roomId.equals(roomId) &
              m.id.isBetweenValues(page * pageSize, (page + 1) * pageSize)))
        .get();
  }

  Stream<Message> getByDbId(int dbId) {
    return (select(messages)..where((m) => m.dbId.equals(dbId))).watchSingle();
  }

  Future<Message> getPendingMessage(int dbId) {
    return (select(messages)..where((m) => m.dbId.equals(dbId))).getSingle();
  }

  Stream getMessagesInCurrentWeek() {
    return (select(messages)
          ..where((m) => m.time.isBiggerOrEqualValue(
              DateTime.now().subtract(Duration(days: DateTime.now().weekday)))))
        .watch();
  }

  Stream getMessageAfterTime(DateTime time) {
    return (select(messages)..where((m) => m.time.isBiggerOrEqualValue(time)))
        .watch();
  }
}
