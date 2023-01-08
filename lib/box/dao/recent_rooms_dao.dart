import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/recent_rooms.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class RecentRoomsDao {
  Future<List<RecentRooms>> getAll();

  Future<void> addRecentRoom(
    String roomId,
  );
}

class RecentRoomsDaoImpl extends RecentRoomsDao {
  @override
  Future<List<RecentRooms>> getAll() async {
    final box = await _open();

    return sorted(box.values);
  }

  List<RecentRooms> sorted(Iterable<RecentRooms> list) =>
      list.toList()..sort((a, b) => b.count.compareTo(a.count));

  @override
  Future<void> addRecentRoom(
    String roomId,
  ) async {
    final box = await _open();
    final count = box.get(roomId)?.count ?? 0;
    if (box.values.length > MAX_RECENT_ROOM_LENGTH - 1 && count == 0) {
      await box.delete(sorted(box.values).last.roomId);
    }

    await box.put(
      roomId,
      RecentRooms(roomId: roomId, count: count + 1),
    );
  }

  static String _key() => "recent-rooms";

  Future<BoxPlus<RecentRooms>> _open() {
    DBManager.open(_key(), TableInfo.RECENT_ROOMS_TABLE_NAME);
    return gen(Hive.openBox<RecentRooms>(_key()));
  }
}
