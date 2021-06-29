import 'package:deliver_flutter/box/last_avatar.dart';
import 'package:hive/hive.dart';

abstract class LastAvatarDao {
  Future<LastAvatar> get(String uid);

  Stream<LastAvatar> getStream(String uid);

  Future<void> save(LastAvatar la);

  Future<void> remove(LastAvatar avatar);
}

class LastAvatarDaoImpl extends LastAvatarDao {
  Future<LastAvatar> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Stream<LastAvatar> getStream(String uid) async* {
    var box = await _open();

    // TODO check if needed
    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  Future<void> save(LastAvatar la) async {
    var box = await _open();

    box.put(la.uid, la);
  }

  Future<void> remove(LastAvatar avatar) async {
    var box = await _open();

    box.delete(avatar.uid);
  }

  static String _key() => "last-avatar";

  static Future<Box<LastAvatar>> _open() => Hive.openBox<LastAvatar>(_key());
}
