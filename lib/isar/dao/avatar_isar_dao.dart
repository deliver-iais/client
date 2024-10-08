import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/isar/avatar_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

class AvatarDaoImpl extends AvatarDao {
  @override
  Stream<List<Avatar>> watchAvatars(String uid) async* {
    final box = await _openAvatarIsar();

    final query = box.avatarIsars
        .filter()
        .uidEqualTo(uid)
        .avatarIsEmptyEqualTo(false)
        .sortByCreatedOnDesc()
        .build();

    yield (await query.findAll()).map((e) => e.fromIsar()).toList();

    yield* query
        .watch()
        .map((event) => event.map((e) => e.fromIsar()).toList());
  }

  @override
  Future<void> saveAvatars(String uid, List<Avatar> avatars) async {
    if (avatars.isEmpty) {
      return;
    }

    final box = await _openAvatarIsar();

    for (final avatar in avatars) {
      await box.writeTxn(() async {
        await box.avatarIsars.put(avatar.toIsar());
      });
    }
  }

  @override
  Future<void> removeAvatar(Avatar avatar) async {
    final box = await _openAvatarIsar();
    final query = box.avatarIsars
        .filter()
        .uidEqualTo(avatar.uid.asString())
        .fileUuidEqualTo(avatar.fileUuid)
        .fileNameEqualTo(avatar.fileName)
        .build();
    return box.writeTxn(() async {
      unawaited(query.deleteAll());
    });
  }

  @override
  Future<Avatar?> getLastAvatar(String uid) async {
    final box = await _openAvatarIsar();
    return (await box.avatarIsars
            .filter()
            .uidEqualTo(uid)
            .sortByCreatedOnDesc()
            .build()
            .findFirst())
        ?.fromIsar();
  }

  @override
  Stream<Avatar?> watchLastAvatar(String uid) async* {
    final box = await _openAvatarIsar();

    final query =
        box.avatarIsars.filter().uidEqualTo(uid).sortByCreatedOnDesc().build();

    yield (await query.findFirst())?.fromIsar();

    yield* query
        .watch()
        .where((event) => event.isNotEmpty)
        .map((event) => event.map((e) => e.fromIsar()).first);
  }

  Future<Isar> _openAvatarIsar() => IsarManager.open();

  @override
  Future<void> clearAllAvatars(String uid) async {
    final box = await _openAvatarIsar();
    final query = box.avatarIsars.filter().uidEqualTo(uid).build();
    return box.writeTxn(() async {
      unawaited(query.deleteAll());
    });
  }

  @override
  Future<void> saveLastAvatarAsNull(String uid) async {
    final box = await _openAvatarIsar();
    final lastAvatar = await getLastAvatar(uid);
    if (lastAvatar == null) {
      return box.writeTxn(() async {
        unawaited(
          box.avatarIsars.put(
            Avatar(
              uid: uid.asUid(),
              fileName: "",
              fileUuid: "",
              lastUpdateTime: clock.now().millisecondsSinceEpoch,
              createdOn: 0,
              avatarIsEmpty: true,
            ).toIsar(),
          ),
        );
      });
    }
  }
}
