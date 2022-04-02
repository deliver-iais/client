import 'package:deliver/box/box_info.dart';
import 'package:hive/hive.dart';

abstract class BlockDao {
  Future<bool> isBlocked(String uid);

  Stream<bool?> watchIsBlocked(String uid);

  Future<void> block(String uid);

  Future<void> unblock(String uid);
}

class BlockDaoImpl implements BlockDao {
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

    box.put(uid, true);
  }

  @override
  Future<void> unblock(String uid) async {
    final box = await _open();

    box.delete(uid);
  }

  static String _key() => "block";

  static Future<Box<bool>> _open() {
    BoxInfo.addBox(_key());
    return Hive.openBox<bool>(_key());
  }
}
