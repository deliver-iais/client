import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class MuteDao extends DBManager {
  Future<bool> isMuted(String uid);

  Stream<bool> watchIsMuted(String uid);

  Future<void> mute(String uid);

  Future<void> unMute(String uid);
}

class MuteDaoImpl extends MuteDao {
  @override
  Future<bool> isMuted(String uid) async {
    final box = await _open();

    return box.get(uid) ?? false;
  }

  @override
  Stream<bool> watchIsMuted(String uid) async* {
    final box = await _open();

    yield box.get(uid) ?? false;

    yield* box.watch(key: uid).map((event) => box.get(uid) ?? false);
  }

  @override
  Future<void> mute(String uid) async {
    final box = await _open();

    return box.put(uid, true);
  }

  @override
  Future<void> unMute(String uid) async {
    final box = await _open();

    return box.delete(uid);
  }

  static String _key() => "mute";

  Future<BoxPlus<bool>> _open() {
    super.open(_key(),MUTE);
    return gen(Hive.openBox<bool>(_key()));
  }
}
