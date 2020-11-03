import 'package:moor/moor.dart';
import '../Mucs.dart';
import '../database.dart';

part 'GroupDao.g.dart';

@UseDao(tables: [Mucs])
class GroupDao extends DatabaseAccessor<Database> with _$GroupDaoMixin {
  final Database database;

  GroupDao(this.database) : super(database);

  Stream watchAllmucs() => select(mucs).watch();

  Future<int> insertMuc(Muc muc) =>
      into(mucs).insertOnConflictUpdate(muc);

  Future deleteMuc(Muc muc) => delete(mucs).delete(muc);

  Future updateMuc(Muc updatedMuc) =>
      update(mucs).replace(updatedMuc);

  Stream<Muc> getByUid(String uid) {
    return (select(mucs)..where((muc) => muc.uid.equals(uid)))
        .watchSingle();
  }


  Future<Muc> getMucByUid(String uid) {
    return (select(mucs)..where((muc) => muc.uid.equals(uid)))
        .getSingle();
  }

  Future<List<Muc>> getMucByName(String text){
    return (select(mucs)..where((muc) => muc.name.equals(text)))
        .get();
  }
}
