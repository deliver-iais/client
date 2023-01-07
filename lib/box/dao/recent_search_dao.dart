import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/recent_search.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class RecentSearchDao {
  Stream<List<RecentSearch>> getAll();

  Future<void> deleteAll();

  Future<void> addRecentSearch(
    String roomId,
    int time,
  );
}

class RecentSearchDaoImpl extends RecentSearchDao {
  @override
  Stream<List<RecentSearch>> getAll() async* {
    final box = await _open();
    yield sorted(box.values);

    yield* box.watch().map(
          (event) => sorted(box.values),
        );
  }

  List<RecentSearch> sorted(Iterable<RecentSearch> list) =>
      list.toList()..sort((a, b) => b.time.compareTo(a.time));

  @override
  Future<void> addRecentSearch(
    String roomId,
    int time,
  ) async {
    final box = await _open();
    final value = box.get(roomId);
    if (box.values.length > MAX_RECENT_SEARCH_LENGTH - 1 && value == null) {
      await box.delete(sorted(box.values).last.roomId);
    }
    await box.put(
      roomId,
      RecentSearch(
        roomId: roomId,
        time: time,
      ),
    );
  }

  @override
  Future<void> deleteAll() async {
    final box = await _open();
    return box.clear();
  }

  static String _key() => "recent-search";

  Future<BoxPlus<RecentSearch>> _open() {
    DBManager.open(_key(), TableInfo.RECENT_SEARCH_TABLE_NAME);
    return gen(Hive.openBox<RecentSearch>(_key()));
  }
}
