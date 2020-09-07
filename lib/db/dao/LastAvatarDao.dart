import 'package:deliver_flutter/db/LastAvatar.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:moor/moor.dart';

part 'LastAvatarDao.g.dart';

@UseDao(tables: [LastAvatars])
class LastAvatarDao extends DatabaseAccessor<Database>
    with _$LastAvatarDaoMixin {
  final Database database;

  LastAvatarDao(this.database) : super(database);

  Future upsert(LastAvatar lastAvatar) =>
      into(lastAvatars).insertOnConflictUpdate(lastAvatar);

  Future deleteLastAvatar(LastAvatar lastAvatar) =>
      delete(lastAvatars).delete(lastAvatar);

  Future<LastAvatar> getLastAvatar(String uid) {
    return (select(lastAvatars)
          ..where((lastAvatar) => lastAvatar.uid.equals(uid)))
        .getSingle();
  }
}
