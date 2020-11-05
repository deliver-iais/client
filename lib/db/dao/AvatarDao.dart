import 'package:deliver_flutter/db/Avatars.dart';
import 'package:moor/moor.dart';
import '../database.dart';

part 'AvatarDao.g.dart';

@UseDao(tables: [Avatars])
class AvatarDao extends DatabaseAccessor<Database> with _$AvatarDaoMixin {
  final Database database;

  AvatarDao(this.database) : super(database);

  Future insertAvatar(Avatar avatar) =>
      into(avatars).insertOnConflictUpdate(avatar);

  Future deleteAvatar(Avatar avatar) => delete(avatars).delete(avatar);

  Stream<List<Avatar>> getByUid(String uid) {
    return (select(avatars)
          ..orderBy([
            (avatar) => OrderingTerm(
                expression: avatar.createdOn, mode: OrderingMode.desc)
          ])
          ..where((avatar) => avatar.uid.equals(uid)))
        .watch();
  }
}
