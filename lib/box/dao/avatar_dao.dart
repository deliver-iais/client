import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/last_avatar.dart';
import 'package:hive/hive.dart';

abstract class AvatarDao {
  Stream<List<Avatar>> watchAvatars(String uid);

  Stream<LastAvatar> watchLastAvatar(String uid);

  Future<LastAvatar> getLastAvatar(String uid);

  Future<void> saveAvatars(String uid, List<Avatar> avatars);

  Future<void> saveLastAvatar(LastAvatar la);

  Future<void> removeAvatar(Avatar avatar);

  Future<void> removeLastAvatar(LastAvatar avatar);

  Future<void> closeAvatarBox(String uid);
}

class AvatarDaoImpl implements AvatarDao {
  Stream<List<Avatar>> watchAvatars(String uid) async* {
    var box = await _open(uid);

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  Future<void> saveAvatars(String uid, List<Avatar> avatars) async {
    if (avatars.isEmpty) return;

    var box = await _open(uid);

    for (var value in avatars) {
      box.put(value.createdOn.toInt().toString(), value);
    }
  }

  Future<void> removeAvatar(Avatar avatar) async {
    var box = await _open(avatar.uid);

    box.delete(avatar.createdOn.toInt().toString());
  }

  static String _key(uid) => "avatar-$uid";

  static Future<Box<Avatar>> _open(String uid) =>
      Hive.openBox<Avatar>(_key(uid));

  Future<void> closeAvatarBox(String uid) =>
      Hive.box<Avatar>(_key(uid)).close();

  Future<LastAvatar> getLastAvatar(String uid) async {
    var box = await _open2();

    return box.get(uid);
  }

  Stream<LastAvatar> watchLastAvatar(String uid) async* {
    var box = await _open2();

    // TODO check if needed
    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  Future<void> saveLastAvatar(LastAvatar la) async {
    var box = await _open2();

    box.put(la.uid, la);
  }

  Future<void> removeLastAvatar(LastAvatar avatar) async {
    var box = await _open2();

    box.delete(avatar.uid);
  }

  static String _key2() => "last-avatar";

  static Future<Box<LastAvatar>> _open2() => Hive.openBox<LastAvatar>(_key2());
}
