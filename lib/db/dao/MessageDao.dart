import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor/moor.dart';
import '../Messages.dart';
import '../database.dart';
import 'dart:async';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

part 'MessageDao.g.dart';

@UseDao(tables: [Messages])
class MessageDao extends DatabaseAccessor<Database> with _$MessageDaoMixin {
  final Database database;

  MessageDao(this.database) : super(database);

  Stream watchAllMessages() => select(messages).watch();

  Future<int> insertMessageCompanion(MessagesCompanion newMessage) =>
      into(messages).insertOnConflictUpdate(newMessage);

  Future<int> insertMessage(Message newMessage) =>
      into(messages).insertOnConflictUpdate(newMessage);

  Future<int> updateMessageId(
      String roomId, String packetID, int id, int time) {
    return (update(messages)
          ..where((t) => t.roomId.equals(roomId) & t.packetId.equals(packetID)))
        .write(
      MessagesCompanion(
          id: Value(id),
          sendingFailed: Value(false),
          time: Value(DateTime.fromMillisecondsSinceEpoch(time))),
    );
  }

  updateMessageTimeAndJson(String roomId, int dbId, String json) {
    (update(messages)
          ..where((t) => t.roomId.equals(roomId) & t.dbId.equals(dbId)))
        .write(
      MessagesCompanion(
        time: Value(DateTime.now()),
        json: Value(json),
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

  Future<Message> getMessageById(int id, String roomId) {
    return (select(messages)
          ..where((m) => m.roomId.equals(roomId) & m.id.equals(id)))
        .getSingle();
  }

  Future<List<Message>> getPage(String roomId, int page,
      {int pageSize = 40}) async {
    return (select(messages)
          ..where((m) =>
              m.roomId.equals(roomId) &
              m.id.isBetweenValues(page * pageSize, (page + 1) * pageSize))
          ..orderBy([
            (m) => OrderingTerm(expression: m.id, mode: OrderingMode.desc),
          ]))
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

  Future<List<Message>> searchMessage(String str, String roomId) {
    return (select(messages)
          ..where((tbl) =>
              tbl.roomId.equals(roomId) &
              tbl.type.equals(MessageType.TEXT.index))
          ..orderBy([
            (m) => OrderingTerm(expression: m.id, mode: OrderingMode.asc),
          ]))
        .get();
  }
}
