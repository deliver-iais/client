import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:hive/hive.dart';

abstract class MetaCountDao {
  Future<void> save(MetaCount metaCount);

  Stream<MetaCount?> get(String roomUid);

  Future<MetaCount?> getAsFuture(String roomUid);

  Future clear(String roomUid);
}

class MetaCountDaoImpl extends MetaCountDao {
  @override
  Stream<MetaCount?> get(String roomUid) async* {
    final box = await _open();

    final res = box.values.where((element) => element.roomId.contains(roomUid));
    if (res.isNotEmpty) {
      yield res.first;
    }
    yield* box.watch().map(
          (event) => box.values
              .where((element) => element.roomId.contains(roomUid))
              .first,
        );
  }

  @override
  Future<void> save(MetaCount metaCount) async {
    final box = await _open();
    return box.put(metaCount.roomId, metaCount);
  }

  @override
  Future<MetaCount?> getAsFuture(String roomUid) async {
    final box = await _open();
    try {
      return box.values.firstWhere((element) => element.roomId == roomUid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future clear(String roomUid) async {
    final box = await _open();
    await box.delete(roomUid);
  }

  static String _key() => "meta_count";

  Future<BoxPlus<MetaCount>> _open() {
    DBManager.open(_key(), TableInfo.META_COUNT_TABLE_NAME);
    return gen(Hive.openBox<MetaCount>(_key()));
  }
}
