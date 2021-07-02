import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MemberRepo {
  var _memberDao = GetIt.I.get<MucDao>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  Cache<String, bool> memberRoleCache =
      LruCache<String, bool>(storage: SimpleStorage(size: 60));

  Future<Member> insertMemberInfo(
      String memberUid, String mucUid, DateTime lastSeen, MucRole role) async {
    Member member = Member(memberUid: memberUid, mucUid: mucUid, role: role);
    await _memberDao.saveMember(member);
    return member;
  }

  Future<List<Member>> searchMemberByNameOrId(
      String mucUid, String query) async {
    // TODO not implemented!!!
    return [];
  }

  Stream<List<Member>> getMembers(String mucUid) {
    return _memberDao.watchAllMembers(mucUid);
  }

  Future<bool> isMucAdminOrOwner(String memberUid, String mucUid) async {
    var member = await _memberDao.getMember(memberUid, mucUid);
    if (member.role == MucRole.OWNER || member.role == MucRole.ADMIN) {
      memberRoleCache[mucUid] = true;
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
