import 'package:deliver_flutter/box/avatar.dart';
import 'package:hive/hive.dart';

class AvatarDao {
  Future<List<Avatar>> get(String uid) async {
    var box = await _open(uid);

    var avatars = box.values.toList();

    box.close();

    return avatars;
  }

  Future<void> save(String uid, List<Avatar> avatars) async {
    var box = await _open(uid);

    for (var value in avatars) {
      box.put(value.createdOn, value);
    }

    box.close();
  }

  Future<void> remove(Avatar avatar) async {
    var box = await _open(avatar.uid);

    box.delete(avatar.createdOn);

    box.close();
  }

  static String _key(uid) => "avatar-$uid";

  static Future<Box<Avatar>> _open(String uid) =>
      Hive.openBox<Avatar>(_key(uid));

  Future<void> close(String uid) => Hive.box<Avatar>(_key(uid)).close();
}
