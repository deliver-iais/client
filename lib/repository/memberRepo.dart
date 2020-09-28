import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/memberType.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:get_it/get_it.dart';

class MemberRepo{
  var _memberDao = GetIt.I.get<MemberDao>();

  Future<Member> insertMemberInfo(String memberUid,String mucUid, DateTime lastSeen, MucRole role) async{
    Member member = Member(memberUid: memberUid, mucUid: mucUid,role:role );
    await _memberDao.insertMember(member);
    return member;
  }

  Stream <List<Member>> getMembers(String mucUid) {

     return  _memberDao.getByMucUid(mucUid);
  }

}