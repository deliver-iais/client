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

  updateLastSeen(LastSeen lastSeenRoom, int lastSeenMessageId) async {
    update(lastSeens)
        .replace(lastSeenRoom.copyWith(messageId: lastSeenMessageId));
  }

  Stream<LastSeen> getByRoomId(String roomId) {
    final query = select(lastSeens)
      ..where((lastSeen) => lastSeen.roomId.equals(roomId));
    if (query == null) insertLastSeen(LastSeen(messageId: -1, roomId: roomId));
    return query.watchSingle();
  }
}
