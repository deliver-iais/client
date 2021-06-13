import 'package:moor/moor.dart';
import '../Seens.dart';
import '../database.dart';

part 'SeenDao.g.dart';

@UseDao(tables: [Seens])
class SeenDao extends DatabaseAccessor<Database> with _$SeenDaoMixin {
  final Database database;

  SeenDao(this.database) : super(database);

  Stream watchAllSeens() => select(seens).watch();

  Future<int> insertSeen(SeensCompanion newSeen) => into(seens).insertOnConflictUpdate(newSeen);

  Future deleteSeen(Seen seen) => delete(seens).delete(seen);

  Future updateSeen(Seen updatedSeen) => update(seens).replace(updatedSeen);

  Stream<Seen> getByRoomIdandUserId(String roomId, String user) {
    return (select(seens)
          ..where(
              (seen) => seen.roomId.equals(roomId) & seen.user.equals(user)))
        .watchSingleOrNull();
  }

  Future<bool> isSeenSentMessage(Message message) async {
    final query = select(seens)..where((s) => s.roomId.equals(message.roomId));
    final res = await query.get();
    for (final row in res) {
      if (row.user != message.from && row.messageId >= message.id) return true;
    }
    return false;
  }

  Future<Seen> getRoomLastSeenId(String roomId) async {
    return (select(seens)
          ..orderBy([
            (s) => OrderingTerm(
                  expression: s.messageId,
                  mode: OrderingMode.desc,
                ),
          ])
          ..where((tbl) => tbl.roomId.equals(roomId))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<Seen> getByMessageId(int messageId, String roomId) {
    return (select(seens)
          ..where(
              (s) => s.messageId.equals(messageId) & s.roomId.equals(roomId)))
        .watchSingleOrNull();
  }

  Stream<Seen> getRoomLastSeen(String roomId) {
    return (select(seens)
          ..orderBy([
            (s) => OrderingTerm(
                  expression: s.messageId,
                  mode: OrderingMode.desc,
                ),
          ])
          ..where((tbl) => tbl.roomId.equals(roomId))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<Seen> getByDBId(int dbId) {
    return (select(seens)..where((s) => s.dbId.equals(dbId))).watchSingleOrNull();
  }
}
