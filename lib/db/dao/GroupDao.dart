import 'package:moor/moor.dart';
import '../Group.dart';
import '../database.dart';

part 'GroupDao.g.dart';

@UseDao(tables: [Groups])
class GroupDao extends DatabaseAccessor<Database> with _$GroupDaoMixin {
  final Database database;

  GroupDao(this.database) : super(database);

  Stream watchAllGroups() => select(groups).watch();

  Future<int> insertGroup(Group newGroup) =>
      into(groups).insertOnConflictUpdate(newGroup);

  Future deleteGroup(Group group) => delete(groups).delete(group);

  Future updateGroup(Group updatedGroup) =>
      update(groups).replace(updatedGroup);

  Stream<Group> getByUid(String uid) {
    return (select(groups)..where((group) => group.uid.equals(uid)))
        .watchSingle();
  }
}
