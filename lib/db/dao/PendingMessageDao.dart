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

  Future<List<PendingMessage>> getAllPendingMessages() =>
      select(pendingMessages).get();

  Future<int> insertPendingMessage(PendingMessage newPendingMessage) =>
      into(pendingMessages).insertOnConflictUpdate(newPendingMessage);

  Future deletePendingMessage(String packetId) async {
    var q = await (select(pendingMessages)
          ..where((pm) => pm.messagePacketId.equals(packetId)))
        .get();
    for (var s in q) {
      delete(pendingMessages).delete(s);
    }
  }


  Future updatePendingMessage(PendingMessage updatedPendingMessage) =>
      update(pendingMessages).replace(updatedPendingMessage);

  Stream<PendingMessage> watchByMessageDbId(int dbId) {
    return (select(pendingMessages)..where((pm) => pm.messageDbId.equals(dbId)))
        .watchSingle();
  }

  Future<PendingMessage> getByMessageDbId(int dbId) {
    return (select(pendingMessages)..where((pm) => pm.messageDbId.equals(dbId)))
        .getSingle();
  }

  Stream<List<PendingMessage>> getByRoomId(String roomId) {
    return (select(pendingMessages)
          ..where((pm) => pm.roomId.equals(roomId))
          ..orderBy([
            (pm) => OrderingTerm(
                expression: pm.messageDbId, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
