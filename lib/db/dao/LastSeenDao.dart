import 'package:moor/moor.dart';

import '../database.dart';
import '../LastSeen.dart';

part 'LastSeenDao.g.dart';

@UseDao(tables: [LastSeens])
class LastSeenDao extends DatabaseAccessor<Database> with _$LastSeenDaoMixin {
  final Database database;

  LastSeenDao(this.database) : super(database);

  Stream watchAllLastSeens() => select(lastSeens).watch();

  Future<int> insertLastSeen(LastSeen newLastSeen) =>
      into(lastSeens).insertOnConflictUpdate(newLastSeen);

  Future deleteLastSeen(LastSeen lastSeen) =>
      delete(lastSeens).delete(lastSeen);

  updateLastSeen(String roomId, int ackId) async {
    (update(lastSeens)
          ..where((lastSeen) =>
              lastSeen.roomId.equals(roomId) &
              lastSeens.messageId.isSmallerThanValue(ackId)))
        .write(LastSeensCompanion(messageId: Value(ackId)));
  }

  Future<LastSeen> getByRoomId(String roomId) async {
    return (select(lastSeens)
          ..where((lastSeen) => lastSeen.roomId.equals(roomId)))
        .getSingle();
  }
}
