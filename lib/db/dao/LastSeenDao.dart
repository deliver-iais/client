import 'package:moor/moor.dart';

import '../database.dart';
import '../LastSeen.dart';

part 'LastSeenDao.g.dart';

@UseDao(tables: [LastSeens])
class LastSeenDao extends DatabaseAccessor<Database> with _$LastSeenDaoMixin {
  final Database database;

  LastSeenDao(this.database) : super(database);

  Future<int> insertLastSeen(LastSeen newLastSeen) =>
      into(lastSeens).insertOnConflictUpdate(newLastSeen);

  Future<LastSeen> getByRoomId(String roomId) async {
    return (select(lastSeens)
          ..where((lastSeen) => lastSeen.roomId.equals(roomId)))
        .getSingleOrNull();
  }

  Stream<LastSeen> watchByRoomId(String roomId) {
    return (select(lastSeens)
      ..where((lastSeen) => lastSeen.roomId.equals(roomId)))
        .watchSingleOrNull();
  }
}
