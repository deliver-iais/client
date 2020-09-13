import 'package:moor/moor.dart';
import '../PendingMessages.dart';
import '../database.dart';

part 'PendingMessageDao.g.dart';

@UseDao(tables: [PendingMessages])
class PendingMessageDao extends DatabaseAccessor<Database>
    with _$PendingMessageDaoMixin {
  final Database database;

  PendingMessageDao(this.database) : super(database);

  Stream watchAllMessages() => select(pendingMessages).watch();

  Future<int> insertPendingMessage(PendingMessage newPendingMessage) =>
      into(pendingMessages).insertOnConflictUpdate(newPendingMessage);

  Future deletePendingMessage(PendingMessage pendingMessage) =>
      delete(pendingMessages).delete(pendingMessage);

  Future updatePendingMessage(PendingMessage updatedPendingMessage) =>
      update(pendingMessages).replace(updatedPendingMessage);

  Stream<List<PendingMessage>> getByMessageId(int messageId) {
    return (select(pendingMessages)
          ..where((pm) => pm.messageId.equals(messageId)))
        .watch();
  }
}
