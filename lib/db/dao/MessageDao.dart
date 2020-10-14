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

  Future<int> insertMessage(Message newMessage) =>
      into(messages).insertOnConflictUpdate(newMessage);

  Future deleteMessage(Message message) => delete(messages).delete(message);

  Future updateMessage(Message updatedMessage) =>
      update(messages).replace(updatedMessage);

  Stream<List<Message>> getByRoomId(String roomId, int lastShowedMessageId) {
    print(roomId);
    // var query = select(messages)
    //   ..orderBy([
    //     (m) => OrderingTerm(expression: m.time, mode: OrderingMode.desc),
    //   ])
    //   ..where((message) => message.roomId.equals(roomId));

    // return MergeStream<List<Message>>([
    // ((query
    //       ..where((message) =>
    //           message.id.isBiggerOrEqualValue(lastShowedMessageId)))
    //       ..limit(40))
    //     .watch(),
    //   ((query
    //         ..where(
    //             (message) => message.id.isSmallerThanValue(lastShowedMessageId))
    //         ..limit(40))
    //       .watch())
    // ]);
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

  Future<List<Message>> getPage(String roomId, int page) async {
    return (select(messages)
          ..where((m) =>
              m.roomId.equals(roomId) &
              m.id.isBetweenValues(page * 50, (page + 1) * 50)))
        .get(); //TODO check
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
