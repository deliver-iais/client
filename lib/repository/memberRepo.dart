import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MemberRepo {
  var _memberDao = GetIt.I.get<MemberDao>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  Cache memberRoleCash =
  LruCache<String, bool>(storage: SimpleStorage(size: 60));

  Future<Member> insertMemberInfo(
      String memberUid, String mucUid, DateTime lastSeen, MucRole role) async {
    Member member = Member(memberUid: memberUid, mucUid: mucUid, role: role);
    await _memberDao.insertMember(member);
    return member;
  }

  Stream<List<Member>> getMembers(String mucUid) {
    return _memberDao.getByMucUid(mucUid);
  }

  Future<bool> isMucAdminOrOwner(String memberUid, String mucUid) async {
    // if(memberRoleCash[mucUid] != null){
    //   return memberRoleCash[mucUid];KKk
    // }
    var member = await _memberDao.getMember(memberUid, mucUid);
    if (member.role == MucRole.OWNER || member.role == MucRole.ADMIN) {
      memberRoleCash[mucUid] = true;
      return true;
    } else if (mucUid.uid.category == Categories.CHANNEL) {
      var res = await _mucRepo.getChannelInfo(mucUid.uid);
      return res.requesterRole == Role.ADMIN;
    }
    return false;
  }

  Future<bool> isOwner(Uid mucUid) async {
    var member = await _memberDao.getMember(
        _accountRepo.currentUserUid.asString(), mucUid.asString());
    if (member.role == MucRole.OWNER) {
      return true;
    }
    return false;
  }

  Future<bool> mucOwner(userUid, mucUid) async {
    var member = await _memberDao.getMember(userUid, mucUid);
    if (member != null) {
      if (member.role == MucRole.OWNER) {
        return true;
      }
    }
    return false;
  }

}
