import 'package:hive/hive.dart';

abstract class MuteDao {
  Future<bool> isMuted(String uid);

  Stream<bool> watchIsMuted(String uid);

  Future<void> mute(String uid);

  Future<void> unmute(String uid);
}

class MuteDaoImpl implements MuteDao {
  Future<bool> isMuted(String uid) async {
    var box = await _open();

    return box.get(uid) ?? false;
  }

  Stream<bool> watchIsMuted(String uid) async* {
    var box = await _open();

    yield box.get(uid) ?? false;

    yield* box.watch(key: uid).map((event) => box.get(uid) ?? false);
  }

  Future<void> mute(String uid) async {
    var box = await _open();

    box.put(uid, true);
  }

  Future<void> unmute(String uid) async {
    var box = await _open();

    box.delete(uid);
  }

  static String _key() => "mute";

  static Future<Box<bool>> _open() => Hive.openBox<bool>(_key());
}
