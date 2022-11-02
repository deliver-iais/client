import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class BlockDao {
  Future<bool> isBlocked(String uid);

  Stream<bool?> watchIsBlocked(String uid);

  Future<void> block(String uid);

  Future<void> unblock(String uid);
}

class BlockDaoImpl extends BlockDao {
  @override
  Future<bool> isBlocked(String uid) async {
    final box = await _open();

    return box.get(uid) ?? false;
  }

  @override
  Stream<bool?> watchIsBlocked(String uid) async* {
    final box = await _open();

    yield box.get(uid) ?? false;

    yield* box.watch(key: uid).map((event) => box.get(uid) ?? false);
  }

  @override
  Future<void> block(String uid) async {
    final box = await _open();

    return box.put(uid, true);
  }

  @override
  Future<void> unblock(String uid) async {
    final box = await _open();

    return box.delete(uid);
  }

  static String _key() => "block";

  Future<BoxPlus<bool>> _open() {
    DBManager.open(_key(), TableInfo.BLOCK_TABLE_NAME);
    return gen(Hive.openBox<bool>(_key()));
  }
}
