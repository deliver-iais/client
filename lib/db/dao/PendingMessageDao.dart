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

  Future<List<PendingMessage>> watchAllMessages() =>
      select(pendingMessages).get();

  Future<int> insertPendingMessage(PendingMessage newPendingMessage) =>
      into(pendingMessages).insertOnConflictUpdate(newPendingMessage);

  Future deletePendingMessage(String packetId) async {
    var q = await (select(pendingMessages)
          ..where((pm) => pm.messagePacketId.equals(packetId)))
        .getSingle();
    delete(pendingMessages).delete(q);
  }

  Future updatePendingMessage(PendingMessage updatedPendingMessage) =>
      update(pendingMessages).replace(updatedPendingMessage);

  Stream<PendingMessage> getByMessageDbId(int dbId) {
    return (select(pendingMessages)..where((pm) => pm.messageDbId.equals(dbId)))
        .watchSingle();
  }

  Stream<List<PendingMessage>> getByRoomId(String roomId) {
    return (select(pendingMessages)
          ..where((pm) => pm.roomId.equals(roomId))
          ..orderBy([
            (pm) => OrderingTerm(
                expression: pm.messageDbId, mode: OrderingMode.asc),
          ]))
        .watch();
  }
  // Future<PendingMessage> getMessage(String messageId) {
  //   return (select(pendingMessages)
  //     ..where((pm) => pm.messageId.equals(messageId)))
  //       .getSingle();
  // }
}
