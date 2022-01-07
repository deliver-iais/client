import 'package:deliver/box/box_info.dart';
import 'package:hive/hive.dart';

abstract class MuteDao {
  Future<bool> isMuted(String uid);

  Stream<bool> watchIsMuted(String uid);

  Future<void> mute(String uid);

  Future<void> unmute(String uid);
}

class MuteDaoImpl implements MuteDao {
  @override
  Future<bool> isMuted(String uid) async {
    var box = await _open();

    return box.get(uid) ?? false;
  }

  @override
  Stream<bool> watchIsMuted(String uid) async* {
    var box = await _open();

    yield box.get(uid) ?? false;

    yield* box.watch(key: uid).map((event) => box.get(uid) ?? false);
  }

  @override
  Future<void> mute(String uid) async {
    var box = await _open();

    box.put(uid, true);
  }

  @override
  Future<void> unmute(String uid) async {
    var box = await _open();

    box.delete(uid);
  }

  static String _key() => "mute";

  static Future<Box<bool>> _open() {
    BoxInfo.addBox(_key());
    return Hive.openBox<bool>(_key());
  }
}
