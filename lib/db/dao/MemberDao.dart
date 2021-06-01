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

  Future updateMember(MembersCompanion updatedMember) =>
      update(members).replace(updatedMember);

  Stream<List<Member>> getByMucUid(String mucUid) {
    return (select(members)..where((member) => member.mucUid.equals(mucUid)))
        .watch();
  }

  Future<List<Member>> getByMucUidFuture(String mucUid, {String query}) {
    return (select(members)
          ..where((member) =>
              member.mucUid.equals(mucUid) &
              (member.username.contains(query)| member.name.contains(query))))
        .get();
  }

  Future<List<Member>> getMembersFuture(String mucUid) {
    return (select(members)
      ..where((member) =>
      member.mucUid.equals(mucUid)))
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
  Future<Member> getMemberByUid(String uid) {
    return (select(members)
      ..where(
              (tbl) => tbl.memberUid.equals(uid)))
        .getSingle();
  }

  Stream<Member> isJoint(String mucId, String uid) {
     return (select(members)
      ..where(
              (tbl) => tbl.memberUid.equals(uid) & tbl.mucUid.equals(mucId)))
        .watchSingle();
  }

  void deleteCurrentMucMember(String mucUid) {
    delete(members)..where((tbl) => tbl.mucUid.equals(mucUid));
  }
}
