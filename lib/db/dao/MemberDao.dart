import 'package:deliver_flutter/db/database.dart';
import 'package:moor/moor.dart';

import '../Member.dart';

part 'MemberDao.g.dart';

@UseDao(tables: [Members])
class MemberDao extends DatabaseAccessor<Database> with _$MemberDaoMixin {
  final Database database;

  MemberDao(this.database) : super(database);

  Stream watchAllMembers() => select(members).watch();

  Future<int> insertMember(Member newMember) =>
      into(members).insertOnConflictUpdate(newMember);

  Future deleteMember(Member member) => delete(members).delete(member);

  Future deleteAllMembers(String mucUid) {
    return (delete(members)..where((t) => t.mucUid.equals(mucUid))).go();
  }

  Future updateMember(Member updatedMember) =>
      update(members).replace(updatedMember);

  Stream<List<Member>> getByMucUid(String mucUid) {
    return (select(members)..where((member) => member.mucUid.equals(mucUid)))
        .watch();
  }

  Future<List<Member>> getByMucUidFuture(String mucUid, {String query}) {
    return (select(members)
          ..where((member) =>
              member.mucUid.equals(mucUid) &
              (member.username.contains(query) | member.name.contains(query))))
        .get();
  }

  Stream<List<Member>> getByMemberId(String memberUid) {
    return (select(members)
          ..where((member) => member.memberUid.equals(memberUid)))
        .watch();
  }

  Future<Member> getMember(String uid, String mucId) {
    return (select(members)
          ..where(
              (tbl) => tbl.memberUid.equals(uid) & tbl.mucUid.equals(mucId)))
        .getSingle();
  }
}
