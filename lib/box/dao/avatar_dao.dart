import 'package:deliver_flutter/box/avatar.dart';
import 'package:hive/hive.dart';

class AvatarDao {
  static Future<List<Avatar>> get(String uid) async {
    var box = await _open(uid);

    var avatars = box.values.toList();

    return avatars;
  }

  static Stream<List<Avatar>> getStream(String uid) async* {
    var box = await _open(uid);

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  static Future<void> save(String uid, List<Avatar> avatars) async {
    if (avatars.isEmpty) return;

    var box = await _open(uid);

    for (var value in avatars) {
      box.put(value.createdOn.toInt().toString(), value);
    }
  }

  static Future<void> remove(Avatar avatar) async {
    var box = await _open(avatar.uid);

    box.delete(avatar.createdOn.toInt().toString());
  }

  static String _key(uid) => "avatar-$uid";

  static Future<Box<Avatar>> _open(String uid) =>
      Hive.openBox<Avatar>(_key(uid));

  Future<void> close(String uid) => Hive.box<Avatar>(_key(uid)).close();
}
