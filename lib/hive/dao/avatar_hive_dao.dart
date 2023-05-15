import 'package:clock/clock.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/hive/avatar_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AvatarDaoImpl extends AvatarDao {
  @override
  Stream<List<Avatar>> watchAvatars(String uid) async* {
    final box = await _open(uid);

    yield sorted(box.values.map((e) => e.fromHive()).toList());

    yield* box
        .watch()
        .map((event) {
      return sorted(box.values.map((e) => e.fromHive()).toList());
    });
  }

  List<Avatar> sorted(List<Avatar> list) {
    list.sort((a, b) => (b.createdOn) - (a.createdOn));
    return list;
  }

  @override
  Future<void> saveAvatars(String uid, List<Avatar> avatars) async {
    if (avatars.isEmpty) {
      return;
    }

    final box = await _open(uid);

    for (final value in avatars) {
      box.put(value.createdOn.toString(), value.toHive()).ignore();
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
        lastAvatarOfList!.uid.asString(),
        lastAvatarOfList
            .copyWith(
              lastUpdateTime: clock.now().millisecondsSinceEpoch,
            )
            .toHive(),
      );
    }
  }

  @override
  Future<void> saveLastAvatarAsNull(String uid) async {
    final box2 = await _open2();

    return box2.put(
      uid,
      AvatarHive(
        uid: uid,
        avatarIsEmpty: true,
        createdOn: 0,
        lastUpdate: clock.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> removeAvatar(Avatar avatar) async {
    final box = await _open(avatar.uid.asString());

    await box.delete(avatar.createdOn.toString());

    final box2 = await _open2();

    final lastAvatar = box2.get(avatar.uid);

    if (avatar.createdOn == lastAvatar!.createdOn) {
      await box2.delete(lastAvatar.uid);

      if (box.values.isNotEmpty) {
        final lastAvatarOfList = box.values.fold<AvatarHive?>(
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

    return box.get(uid)?.fromHive();
  }

  @override
  Stream<Avatar?> watchLastAvatar(String uid) async* {
    final box = await _open2();

    yield box.get(uid)?.fromHive();

    yield* box.watch(key: uid).map((event) {
      return box.get(uid)?.fromHive();
    });
  }

  static String _key(uid) => "avatar-$uid";

  static String _key2() => "last-avatar";

  Future<BoxPlus<AvatarHive>> _open(String uid) {
    DBManager.open(_key(uid.replaceAll(":", "-")), TableInfo.AVATAR_TABLE_NAME);
    return gen(Hive.openBox<AvatarHive>(_key(uid.replaceAll(":", "-"))));
  }

  Future<void> closeAvatarBox(String uid) =>
      Hive.box<AvatarHive>(_key(uid)).close();

  Future<BoxPlus<AvatarHive>> _open2() {
    DBManager.open(_key2(), TableInfo.LAST_AVATAR_TABLE_NAME);
    return gen(Hive.openBox<AvatarHive>(_key2()));
  }

  @override
  Future<void> clearAllAvatars(String uid) async {
    final box = await _open(uid);
    return box.clear();
  }
}
