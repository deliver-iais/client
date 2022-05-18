import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class MuteDao {
  Future<bool> isMuted(String uid);

  Stream<bool> watchIsMuted(String uid);

  Future<void> mute(String uid);

  Future<void> unMute(String uid);
}

class MuteDaoImpl implements MuteDao {
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

  static Future<BoxPlus<bool>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<bool>(_key()));
  }
}
