import 'package:deliver_flutter/box/avatar.dart';
import 'package:hive/hive.dart';

abstract class AvatarDao {
  Stream<List<Avatar>> watchAvatars(String uid);

  Stream<Avatar> watchLastAvatar(String uid);

  Future<Avatar> getLastAvatar(String uid);

  Future<void> saveAvatars(String uid, List<Avatar> avatars);

  Future<void> saveLastAvatarAsNull(String uid);

  Future<void> removeAvatar(Avatar avatar);

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
      box.put(value.createdOn.toString(), value);
    }

    await saveLastAvatar(avatars, uid);
  }

  Future<void> saveLastAvatar(List<Avatar> avatars, String uid) async {
    var box2 = await _open2();

    var lastAvatarOfList = avatars.fold<Avatar>(
        null,
        (value, element) => value == null
            ? element
            : value.createdOn > element.createdOn
                ? value
                : element);

    var lastAvatar = box2.get(uid);

    if (lastAvatar == null ||
        lastAvatar.createdOn < lastAvatarOfList.createdOn) {
      box2.put(
          lastAvatarOfList.uid,
          lastAvatarOfList.copyWith(
              lastUpdate: DateTime.now().millisecondsSinceEpoch));
    }
  }

  @override
  Future<void> saveLastAvatarAsNull(String uid) async {
    var box2 = await _open2();

    box2.put(
        uid,
        Avatar(
            uid: uid,
            createdOn: 0,
            lastUpdate: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> removeAvatar(Avatar avatar) async {
    var box = await _open(avatar.uid);

    await box.delete(avatar.createdOn.toString());

    var box2 = await _open2();

    var lastAvatar = box2.get(avatar.uid);

    if (avatar.createdOn == lastAvatar.createdOn) {
      await box2.delete(lastAvatar.uid);

      if (box.values.length > 0) {
        var lastAvatarOfList = box.values.fold<Avatar>(
            null,
            (value, element) => value == null
                ? element
                : value.createdOn > element.createdOn
                    ? value
                    : element);

        box2.put(
            lastAvatarOfList.uid,
            lastAvatarOfList.copyWith(
                lastUpdate: DateTime.now().millisecondsSinceEpoch));
      }
    }
  }

  Future<Avatar> getLastAvatar(String uid) async {
    var box = await _open2();

    return box.get(uid);
  }

  Stream<Avatar> watchLastAvatar(String uid) async* {
    var box = await _open2();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  static String _key(uid) => "avatar-$uid";

  static String _key2() => "last-avatar";

  static Future<Box<Avatar>> _open(String uid) =>
      Hive.openBox<Avatar>(_key(uid.replaceAll(":", "-")));

  Future<void> closeAvatarBox(String uid) =>
      Hive.box<Avatar>(_key(uid)).close();

  static Future<Box<Avatar>> _open2() => Hive.openBox<Avatar>(_key2());
}
