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

  updateLastSeen(String roomId, int lastSeenMessageId) async {
    LastSeen lastSeenRoom = await (select(lastSeens)
          ..where((lastSeen) => lastSeen.roomId.equals(roomId)))
        .getSingle();
    if (lastSeenRoom == null)
      await insertLastSeen(
          LastSeen(messageId: lastSeenMessageId, roomId: roomId));
    else if (lastSeenRoom.messageId != lastSeenMessageId)
      update(lastSeens)
          .replace(lastSeenRoom.copyWith(messageId: lastSeenMessageId));
  }

  Future<LastSeen> getByRoomId(String roomId) {
    return (select(lastSeens)
          ..where((lastSeen) => lastSeen.roomId.equals(roomId)))
        .getSingle();
  }
}
