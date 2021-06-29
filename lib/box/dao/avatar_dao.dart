import 'package:deliver_flutter/box/avatar.dart';
import 'package:hive/hive.dart';

abstract class AvatarDao {
  Stream<List<Avatar>> watch(String uid);

  Future<void> save(String uid, List<Avatar> avatars);

  Future<void> remove(Avatar avatar);

  Future<void> close(String uid);
}

class AvatarDaoImpl implements AvatarDao {
  Stream<List<Avatar>> watch(String uid) async* {
    var box = await _open(uid);

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  Future<void> save(String uid, List<Avatar> avatars) async {
    if (avatars.isEmpty) return;

    var box = await _open(uid);

    for (var value in avatars) {
      box.put(value.createdOn.toInt().toString(), value);
    }
  }

  Future<void> remove(Avatar avatar) async {
    var box = await _open(avatar.uid);

    box.delete(avatar.createdOn.toInt().toString());
  }

  static String _key(uid) => "avatar-$uid";

  static Future<Box<Avatar>> _open(String uid) =>
      Hive.openBox<Avatar>(_key(uid));

  Future<void> close(String uid) => Hive.box<Avatar>(_key(uid)).close();
}
