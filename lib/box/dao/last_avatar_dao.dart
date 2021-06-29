import 'package:deliver_flutter/box/last_avatar.dart';
import 'package:hive/hive.dart';

class LastAvatarDao {
  static Future<LastAvatar> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  static Stream<LastAvatar> getStream(String uid) async* {
    var box = await _open();

    // TODO check if needed
    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  static Future<void> save(LastAvatar la) async {
    var box = await _open();

    box.put(la.uid, la);
  }

  static Future<void> remove(LastAvatar avatar) async {
    var box = await _open();

    box.delete(avatar.uid);
  }

  static String _key() => "last-avatar";

  static Future<Box<LastAvatar>> _open() => Hive.openBox<LastAvatar>(_key());
}
