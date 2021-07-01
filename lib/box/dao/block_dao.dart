import 'package:hive/hive.dart';

abstract class BlockDao {
  Future<bool> isBlocked(String uid);

  Future<void> block(String uid);

  Future<void> unblock(String uid);
}

class BlockDaoImpl implements BlockDao {
  Future<bool> isBlocked(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Future<void> block(String uid) async {
    var box = await _open();

    box.put(uid, true);
  }

  Future<void> unblock(String uid) async {
    var box = await _open();

    box.delete(uid);
  }

  static String _key() => "block";

  static Future<Box<bool>> _open() => Hive.openBox<bool>(_key());
}
