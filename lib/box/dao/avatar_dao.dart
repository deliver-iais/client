import 'dart:async';

import 'package:deliver/box/avatar.dart';

abstract class AvatarDao {
  Stream<List<Avatar?>> watchAvatars(String uid);

  Stream<Avatar?> watchLastAvatar(String uid);

  Future<Avatar?> getLastAvatar(String uid);

  Future<void> saveAvatars(String uid, List<Avatar> avatars);

  Future<void> saveLastAvatarAsNull(String uid);

  Future<void> removeAvatar(Avatar avatar);

  Future<void> clearAllAvatars(String uid);
}
