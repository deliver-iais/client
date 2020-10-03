import 'package:moor/moor.dart';
import '../Messages.dart';
import '../database.dart';

part 'MessageDao.g.dart';

@UseDao(tables: [Messages])
class MessageDao extends DatabaseAccessor<Database> with _$MessageDaoMixin {
  final Database database;

  MessageDao(this.database) : super(database);

  Stream watchAllMessages() => select(messages).watch();

  Future<int> insertMessage(Message newMessage) =>
      into(messages).insertOnConflictUpdate(newMessage);

  Future deleteMessage(Message message) => delete(messages).delete(message);

  Future updateMessage(Message updatedMessage) =>
      update(messages).replace(updatedMessage);

  Stream<List<Message>> getByRoomId(String roomId) {
    return (select(messages)
          ..orderBy([
            (m) => OrderingTerm(expression: m.time, mode: OrderingMode.desc)
          ])
          ..where((message) => message.roomId.equals(roomId)))
        .watch();
  }

  Stream<Message> getById(int id, String roomId) {
    return (select(messages)
          ..where((m) => m.roomId.equals(roomId) & m.id.equals(id)))
        .watchSingle();
  }

  Stream<Message> getByDBId(String dbId) {
    return (select(messages)..where((m) => m.packetId.equals(dbId)))
        .watchSingle();
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
