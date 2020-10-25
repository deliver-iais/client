import 'package:moor/moor.dart';
import '../Messages.dart';
import '../PendingMessages.dart';
import '../database.dart';

part 'PendingMessageDao.g.dart';

@UseDao(tables: [PendingMessages, Messages])
class PendingMessageDao extends DatabaseAccessor<Database>
    with _$PendingMessageDaoMixin {
  final Database database;

  PendingMessageDao(this.database) : super(database);

  Stream<List<PendingMessage>> watchAllMessages() =>
      select(pendingMessages).watch();

  Future<int> insertPendingMessage(PendingMessage newPendingMessage) =>
      into(pendingMessages).insertOnConflictUpdate(newPendingMessage);

  Future deletePendingMessage(PendingMessage pendingMessage) =>
      delete(pendingMessages).delete(pendingMessage);

  Future updatePendingMessage(PendingMessage updatedPendingMessage) =>
      update(pendingMessages).replace(updatedPendingMessage);

  Stream<List<PendingMessage>> getByMessageDbId(int dbId) {
    return (select(pendingMessages)..where((pm) => pm.messageDbId.equals(dbId)))
        .watch();
  }

  Stream<List<PendingMessage>> getByRoomId(String roomId) {
    return (select(pendingMessages)..where((pm) => pm.roomId.equals(roomId)))
        .watch();
  }

  Future<int> getMessageNumber(String roomId) {
    return (select(pendingMessages)..where((pm) => pm.roomId.equals(roomId)))
        .watch()
        .length;
  }
}
