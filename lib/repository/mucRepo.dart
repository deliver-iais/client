import 'package:deliver_flutter/box/dao/message_dao.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/box/role.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/box/uid_id_name.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/group.pb.dart' as MucPro;
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart' as MucPro;
import 'package:deliver_public_protocol/pub/v1/models/muc.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:grpc/grpc.dart';

class MucRepo {
  final _mucDao = GetIt.I.get<MucDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _queryServices = GetIt.I.get<QueryServiceClient>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();

  Future<Uid> createNewGroup(
      List<Uid> memberUids, String groupName, String info) async {
    Uid groupUid = await _mucServices.createNewGroup(groupName, info);
    if (groupUid != null) {
      sendMembers(groupUid, memberUids);
      _insertToDb(groupUid, groupName, memberUids.length + 1, info);
      return groupUid;
    }
    return null;
  }

  Future<Uid> createNewChannel(String channelId, List<Uid> memberUids,
      String channelName, ChannelType channelType, String info) async {
    Uid channelUid = await _mucServices.createNewChannel(
        channelName, channelType, channelId, info);

    if (channelUid != null) {
      sendMembers(channelUid, memberUids);
      _mucDao.saveMember(Member(
          memberUid: _accountRepo.currentUserUid.asString(),
          mucUid: channelUid.asString(),
          role: MucRole.OWNER));
      _insertToDb(channelUid, channelName, memberUids.length + 1, info,
          channelId: channelId);
      fetchMucInfo(channelUid);
      return channelUid;
    }

    fetchChannelMembers(channelUid, memberUids.length);
    return null;
  }

  Future<bool> channelIdIsAvailable(String id) async {
    var result = await _queryServices.idIsAvailable(IdIsAvailableReq()..id = id,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    return result.isAvailable;
  }

  fetchGroupMembers(Uid groupUid, int len) async {
    try {
      int i = 0;
      int membersSize = 0;

      bool finish = false;
      List<Member> members = [];
      while (i <= len || !finish) {
        var result = await _mucServices.getGroupMembers(groupUid, 15, i);
        if (len == 0) membersSize = membersSize + result.members.length;
        for (MucPro.Member member in result.members) {
          try {
            members.add(Member(
                mucUid: groupUid.asString(),
                memberUid: member.uid.asString(),
                role: getLocalRole(member.role)));
          } catch (e) {
            debug(e.toString());
          }
        }
        finish = result.finished;
        i = i + 15;
      }
      insertUserInDb(groupUid, members);
      if (len <= membersSize)
        _mucDao.update(Muc(uid: groupUid.asString(), population: membersSize));
    } catch (e) {
      debug(e.toString());
    }
  }

  Future getGroupJointToken({Uid groupUid}) async {
    return await _mucServices.getGroupJointToken(groupUid: groupUid);
  }

  Future getChannelJointToken({Uid channelUid}) async {
    return await _mucServices.getChannelJointToken(channelUid: channelUid);
  }

  fetchChannelMembers(Uid channelUid, int len) async {
    try {
      int i = 0;
      int membersSize = 0;
      bool finish = false;
      List<Member> members = [];
      while (i <= len || !finish) {
        var result = await _mucServices.getChannelMembers(channelUid, 15, i);
        if (len == 0) membersSize = membersSize + result.members.length;
        for (MucPro.Member member in result.members) {
          try {
            members.add(Member(
                mucUid: channelUid.asString(),
                memberUid: member.uid.asString(),
                role: getLocalRole(member.role)));
          } catch (e) {
            debug(e.toString());
          }
        }

        finish = result.finished;
        i = i + 15;
        if (len <= membersSize)
          _mucDao
              .update(Muc(uid: channelUid.asString(), population: membersSize));
      }
      insertUserInDb(channelUid, members);
    } catch (e) {
      debug(e.toString());
    }
  }

  Future<Muc> fetchMucInfo(Uid mucUid) async {
    if (mucUid.category == Categories.GROUP) {
      MucPro.GetGroupRes group = await _mucServices.getGroup(mucUid);
      if (group != null) {
        var muc = Muc(
          name: group.info.name,
          population: group.population.toInt(),
          uid: mucUid.asString(),
          info: group.info.info,
          token: group.token,
          pinMessagesIdList: group.pinMessages.map((e) => e.toInt()).toList(),
        );

        _mucDao.save(muc);

        fetchGroupMembers(mucUid, group.population.toInt());
        return muc;
      }
      return null;
    } else {
      GetChannelRes channel = await getChannelInfo(mucUid);
      if (channel != null) {
        var muc = Muc(
            name: channel.info.name,
            population: channel.population.toInt(),
            uid: mucUid.asString(),
            info: channel.info.info,
            token: channel.token,
            pinMessagesIdList:
                channel.pinMessages.map((e) => e.toInt()).toList(),
            id: channel.info.id);

        _mucDao.save(muc);
        insertUserInDb(mucUid, [
          Member(
              memberUid: _accountRepo.currentUserUid.asString(),
              mucUid: mucUid.asString(),
              role: getLocalRole(channel.requesterRole))
        ]);
        if (channel.requesterRole != MucPro.Role.NONE)
          fetchChannelMembers(mucUid, channel.population.toInt());
        return muc;
      }
      return null;
    }
  }

  Future<bool> isMucAdminOrOwner(String memberUid, String mucUid) async {
    var member = await _mucDao.getMember(memberUid, mucUid);
    if (member.role == MucRole.OWNER || member.role == MucRole.ADMIN) {
      return true;
    } else if (mucUid.asUid().category == Categories.CHANNEL) {
      var res = await getChannelInfo(mucUid.asUid());
      return res.requesterRole == Role.ADMIN || res.requesterRole == Role.OWNER;
    }
    return false;
  }

  Future<bool> mucOwner(userUid, mucUid) async {
    var member = await _mucDao.getMember(userUid, mucUid);
    if (member != null) {
      if (member.role == MucRole.OWNER) {
        return true;
      }
    }
    return false;
  }

  Future<List<Member>> searchMemberByNameOrId(String mucUid) async {
    return [];
  }

  Future<List<Member>> getAllMembers(String mucUid) =>
      _mucDao.getAllMembers(mucUid);

  Stream<List<Member>> watchAllMembers(String mucUid) =>
      _mucDao.watchAllMembers(mucUid);

  Future<Muc> getMuc(String mucUid) => _mucDao.get(mucUid);

  Stream<Muc> watchMuc(String mucUid) => _mucDao.watch(mucUid);

  // TODO there is bugs in delete member, where is memberUid ?!?!?
  Future<bool> removeGroup(Uid groupUid) async {
    var result = await _mucServices.removeGroup(groupUid);
    if (result) {
      _mucDao.delete(groupUid.asString());
      _roomDao.updateRoom(Room(uid: groupUid.asString(), deleted: true));
      _mucDao.deleteAllMembers(groupUid.asString());
      return true;
    }
    return false;
  }

  Future<bool> removeChannel(Uid channelUid) async {
    var result = await _mucServices.removeChannel(channelUid);
    if (result) {
      _mucDao.delete(channelUid.asString());
      _roomDao.updateRoom(Room(uid: channelUid.asString(), deleted: true));
      _mucDao.deleteAllMembers(channelUid.asString());
      return true;
    }
    return false;
  }

  Future<GetChannelRes> getChannelInfo(Uid channelUid) async {
    return await _mucServices.getChannel(channelUid);
  }

  changeGroupMemberRole(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    bool result =
        await _mucServices.changeGroupRole(member, groupMember.mucUid.asUid());
    if (result) {
      _mucDao.saveMember(groupMember);
    }
  }

  changeChannelMemberRole(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = channelMember.memberUid.asUid()
      ..role = getRole(channelMember.role);
    var result = await _mucServices.changeCahnnelRole(
        member, channelMember.mucUid.asUid());
    if (result) {
      _mucDao.saveMember(channelMember);
    }
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    var result = await _mucServices.leaveGroup(groupUid);
    if (result) {
      _mucDao.delete(groupUid.asString());
      _roomDao.updateRoom(Room(uid: groupUid.asString(), deleted: true));
      return true;
    }
    return false;
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    var result = await _mucServices.leaveChannel(channelUid);
    if (result) {
      _mucDao.delete(channelUid.asString());
      _roomDao.updateRoom(Room(uid: channelUid.asString(), deleted: true));
      return true;
    }
    return false;
  }

  kickGroupMembers(List<Member> groupMember) async {
    List<MucPro.Member> members = [];
    for (Member member in groupMember) {
      members.add(MucPro.Member()
        ..uid = member.memberUid.asUid()
        ..role = getRole(member.role));
    }

    bool result = await _mucServices.kickGroupMembers(
        members, groupMember[0].mucUid.asUid());

    if (result) {
      for (Member member in groupMember) _mucDao.deleteMember(member);
    }
  }

  kickChannelMembers(List<Member> channelMember) async {
    List<MucPro.Member> members = [];
    for (Member member in channelMember) {
      members.add(MucPro.Member()
        ..uid = member.memberUid.asUid()
        ..role = getRole(member.role));
    }
    var result = await _mucServices.kickChannelMembers(
        members, channelMember[0].mucUid.asUid());
    if (result) {
      for (Member member in channelMember) _mucDao.deleteMember(member);
    }
  }

  banGroupMember(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    await _mucServices.banGroupMember(member, groupMember.mucUid.asUid());
    //todo change database
  }

  banChannelMember(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = channelMember.memberUid.asUid()
      ..role = getRole(channelMember.role);
    await _mucServices.unbanChannelMember(member, channelMember.mucUid.asUid());
    //todo change database
  }

  unBanGroupMember(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    await _mucServices.banGroupMember(member, groupMember.mucUid.asUid());
    //todo change databse
  }

  unBanChannelMember(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = channelMember.memberUid.asUid()
      ..role = getRole(channelMember.role);
    await _mucServices.unbanChannelMember(member, channelMember.mucUid.asUid());
    //todo change database
  }

  joinGroup(Uid groupUid, String token) async {
    var result = await _mucServices.joinGroup(groupUid, token);
    if (result) {
      fetchMucInfo(groupUid);
      return true;
    }
    return false;
  }

  joinChannel(Uid channelUid, String token) async {
    var result = await _mucServices.joinChannel(channelUid, token);
    if (result) {
      fetchMucInfo(channelUid);
      return true;
    }
    return false;
  }

  modifyGroup(String mucId, String name, String info) async {
    var isSet = await _mucServices.modifyGroup(
        MucPro.GroupInfo()
          ..name = name
          ..info = info,
        mucId.asUid());
    if (isSet) {
      _mucDao.update(Muc(uid: mucId, name: name, info: info));
    }
  }

  modifyChannel(String mucUid, String name, String id, String info) async {
    ChannelInfo channelInfo;
    channelInfo = id.isEmpty
        ? (ChannelInfo()
          ..name = name
          ..info = info)
        : ChannelInfo()
      ..name = name
      ..id = id
      ..info = info;

    if (await _mucServices.modifyChannel(channelInfo, mucUid.asUid())) {
      if (id.isEmpty) {
        _mucDao.update(Muc(uid: mucUid, name: name, info: info));
      } else {
        _mucDao.update(Muc(uid: mucUid, name: name, id: id, info: info));
      }
    }
  }

  _insertToDb(Uid mucUid, String mucName, int memberCount, String info,
      {String channelId}) async {
    await _mucDao.save(Muc(
        uid: mucUid.asString(),
        name: mucName,
        info: info,
        population: memberCount,
        id: channelId));
    await _roomDao.updateRoom(Room(uid: mucUid.asString()));
  }

  Future<bool> sendMembers(Uid mucUid, List<Uid> memberUids) async {
    try {
      bool usersAdd = false;
      List<MucPro.Member> members = [];
      for (Uid uid in memberUids) {
        members.add(MucPro.Member()
          ..uid = uid
          ..role = MucPro.Role.MEMBER);
      }

      if (mucUid.category == Categories.GROUP) {
        usersAdd = await _mucServices.addGroupMembers(members, mucUid);
      } else {
        usersAdd = await _mucServices.addChannelMembers(members, mucUid);
      }

      if (usersAdd) {
        if (mucUid.category == Categories.GROUP) {
          fetchGroupMembers(mucUid, members.length);
        } else {
          fetchChannelMembers(mucUid, members.length);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  insertUserInDb(Uid mucUid, List<Member> members) async {
    if (members.length > 0) {
      await _mucDao.deleteAllMembers(mucUid.asString());
    }
    for (Member member in members) {
      _mucDao.saveMember(member);
    }
  }

  MucPro.Role getRole(MucRole role) {
    switch (role) {
      case MucRole.MEMBER:
        return MucPro.Role.MEMBER;
        break;
      case MucRole.ADMIN:
        return MucPro.Role.ADMIN;
        break;
      case MucRole.OWNER:
        return MucPro.Role.OWNER;
      case MucRole.NONE:
        return MucPro.Role.NONE;
        break;
    }
    return MucPro.Role.NONE;
  }

  MucRole getLocalRole(Role role) {
    switch (role) {
      case Role.MEMBER:
        return MucRole.MEMBER;
        break;
      case Role.ADMIN:
        return MucRole.ADMIN;
        break;
      case Role.OWNER:
        return MucRole.OWNER;
      case Role.NONE:
        return MucRole.NONE;
        break;
    }
    throw Exception("Not Valid Role! $role");
  }

  String getAsInt(List<Int64> pinMessages) {
    String pm = "";
    pinMessages.forEach((element) {
      pm = "$pm , ${element.toString()} ,";
    });
    return pm;
  }

  Future<List<UidIdName>> getFilteredMember(String roomUid,
      {String query}) async {
    List<UidIdName> _mucMembers = [];
    List<UidIdName> _filteredMember = [];

    var res = await getAllMembers(roomUid);
   await res.forEach((member) async {
      if (_accountRepo.isCurrentUser(member.memberUid)) {
        var a = await _accountRepo.getAccount();
        _mucMembers.add(UidIdName(
            uid: member.memberUid, id: a.userName, name: a.firstName));
      } else {
        var s = await _uidIdNameDao.getByUid(member.memberUid);
        _mucMembers.add(s);
      }
    });
    if (query.isNotEmpty) {
      _mucMembers.forEach((element) {
        if (element.id.contains(query) ||
            (element.name != null && element.name.contains(query))) {
          _filteredMember.add(element);
        }
      });
      return _filteredMember;
    } else
      return _mucMembers;
  }
}
