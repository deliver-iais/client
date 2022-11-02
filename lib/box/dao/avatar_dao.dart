import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class AvatarDao extends DBManager {
  Stream<List<Avatar?>> watchAvatars(String uid);

  Stream<Avatar?> watchLastAvatar(String uid);

  Future<Avatar?> getLastAvatar(String uid);

  Future<void> saveAvatars(String uid, List<Avatar> avatars);

  Future<void> saveLastAvatarAsNull(String uid);

  Future<void> removeAvatar(Avatar avatar);

  Future<void> closeAvatarBox(String uid);

  Future<void> clearAllAvatars(String uid);
}

class AvatarDaoImpl extends AvatarDao {
  @override
  Stream<List<Avatar>> watchAvatars(String uid) async* {
    final box = await _open(uid);

    yield sorted(box.values.toList());

    yield* box.watch().map((event) => sorted(box.values.toList()));
  }

  List<Avatar> sorted(List<Avatar> list) {
    list.sort((a, b) => (b.createdOn) - (a.createdOn));
    return list;
  }

  @override
  Future<void> saveAvatars(String uid, List<Avatar> avatars) async {
    if (avatars.isEmpty) return;

    final box = await _open(uid);

    for (final value in avatars) {
      box.put(value.createdOn.toString(), value).ignore();
    }

    return saveLastAvatar(avatars, uid);
  }

  Future<void> saveLastAvatar(List<Avatar> avatars, String uid) async {
    final box2 = await _open2();
    final box = await _open(uid);

    final lastAvatarOfList = avatars.fold<Avatar?>(
      null,
      (value, element) => value == null
          ? element
          : value.createdOn > element.createdOn
              ? value
              : element,
    );

    final lastAvatar = box2.get(uid);

    if (lastAvatar == null ||
        lastAvatar.createdOn < lastAvatarOfList!.createdOn ||
        box.values.length == 1) {
      return box2.put(
        lastAvatarOfList!.uid,
        lastAvatarOfList.copyWith(
          lastUpdate: clock.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  @override
  Future<void> saveLastAvatarAsNull(String uid) async {
    final box2 = await _open2();

    return box2.put(
      uid,
      Avatar(
        uid: uid,
        createdOn: 0,
        lastUpdate: clock.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> removeAvatar(Avatar avatar) async {
    final box = await _open(avatar.uid);

    await box.delete(avatar.createdOn.toString());

    final box2 = await _open2();

    final lastAvatar = box2.get(avatar.uid);

    if (avatar.createdOn == lastAvatar!.createdOn) {
      await box2.delete(lastAvatar.uid);

      if (box.values.isNotEmpty) {
        final lastAvatarOfList = box.values.fold<Avatar?>(
          null,
          (value, element) => value == null
              ? element
              : value.createdOn > element.createdOn
                  ? value
                  : element,
        );

        return box2.put(
          lastAvatarOfList!.uid,
          lastAvatarOfList.copyWith(
            lastUpdate: clock.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  @override
  Future<Avatar?> getLastAvatar(String uid) async {
    final box = await _open2();

    return box.get(uid);
  }

  @override
  Stream<Avatar?> watchLastAvatar(String uid) async* {
    final box = await _open2();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  static String _key(uid) => "avatar-$uid";

  static String _key2() => "last-avatar";

  Future<BoxPlus<Avatar>> _open(String uid) {
    super.open(_key(uid.replaceAll(":", "-")), TableInfo.AVATAR_TABLE_NAME);
    return gen(Hive.openBox<Avatar>(_key(uid.replaceAll(":", "-"))));
  }

  @override
  Future<void> closeAvatarBox(String uid) =>
      Hive.box<Avatar>(_key(uid)).close();

  Future<BoxPlus<Avatar>> _open2() {
    super.open(_key2(), TableInfo.AVATAR_TABLE_NAME);
    return gen(Hive.openBox<Avatar>(_key2()));
  }

  @override
  Future<void> clearAllAvatars(String uid) async {
    final box = await _open(uid);
    return box.clear();
  }
}
