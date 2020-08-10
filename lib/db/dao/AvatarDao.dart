import 'package:deliver_flutter/db/Avatars.dart';
import 'package:moor_flutter/moor_flutter.dart';
import '../database.dart';

part 'AvatarDao.g.dart';

@UseDao(tables: [Avatars])
class AvatarDao extends DatabaseAccessor<Database> with _$AvatarDaoMixin {
  final Database database;

  AvatarDao(this.database) : super(database);

  Future insetAvatar(Avatar avatar) => into(avatars).insert(avatar);

  Future deleteAvatar(Avatar avatar) => delete(avatars).delete(avatar);

  Future<List<Avatar>> getByUid(String uid) {
    return (select(avatars)..where((avatar) => avatar.uid.equals(uid))).get();
  }
}
