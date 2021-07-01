import 'package:moor/moor.dart';
import '../Mucs.dart';
import '../database.dart';

part 'MucDao.g.dart';

@UseDao(tables: [Mucs])
class MucDao extends DatabaseAccessor<Database> with _$MucDaoMixin {
  final Database database;

  MucDao(this.database) : super(database);

  Stream watchAllmucs() => select(mucs).watch();

  Future<int> insertMuc(Muc muc) => into(mucs).insertOnConflictUpdate(muc);

  Future<int> upsertMucCompanion(MucsCompanion muc) {
    return into(mucs).insertOnConflictUpdate(muc);
  }

  Future deleteMuc(String mucUid) {
    return (delete(mucs)..where((t) => t.uid.equals(mucUid))).go();
  }

  Future updateMuc(String mucUid, int members) =>
      (update(mucs)..where((t) => t.uid.equals(mucUid))).write(
        MucsCompanion(members: Value(members)),
      );

  Future<Muc> get(String uid) {
    return (select(mucs)..where((muc) => muc.uid.equals(uid))).getSingleOrNull();
  }

  Stream<Muc> watch(String uid) {
    return (select(mucs)..where((muc) => muc.uid.equals(uid))).watchSingleOrNull();
  }

  Future<List<Muc>> getMucByName(String text) {
    return (select(mucs)..where((muc) => muc.name.contains(text))).get();
  }
}
