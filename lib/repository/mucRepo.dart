import 'dart:convert';

import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
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
import 'package:moor/moor.dart';

class MucRepo {
  MucDao _mucDao = GetIt.I.get<MucDao>();
  MemberDao _memberDao = GetIt.I.get<MemberDao>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  var mucServices = GetIt.I.get<MucServices>();
  var accountRepo = GetIt.I.get<AccountRepo>();
  var messageDao = GetIt.I.get<MessageDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var contactDao = GetIt.I.get<ContactDao>();
  var _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  var _queryServices = GetIt.I.get<QueryServiceClient>();

  var _accountRepo = GetIt.I.get<AccountRepo>();

  Future<Uid> createNewGroup(
      List<Uid> memberUids, String groupName, String info) async {
    Uid groupUid = await mucServices.createNewGroup(groupName, info);
    if (groupUid != null) {
      sendMembers(groupUid, memberUids);
      _insertToDb(groupUid, groupName, memberUids.length + 1, info);
      return groupUid;
    }
    return null;
  }

  Future<Uid> createNewChannel(String channelId, List<Uid> memberUids,
      String channelName, ChannelType channelType, String info) async {
    Uid channelUid = await mucServices.createNewChannel(
        channelName, channelType, channelId, info);

    if (channelUid != null) {
      sendMembers(channelUid, memberUids);
      _memberDao.insertMember(Member(
          memberUid: _accountRepo.currentUserUid.asString(),
          mucUid: channelUid.asString(),
          role: MucRole.OWNER));
      _insertToDb(channelUid, channelName, memberUids.length + 1, info,
          channelId: channelId);
      fetchMucInfo(channelUid);
      return channelUid;
    }

    getChannelMembers(channelUid, memberUids.length);
    return null;
  }

  Future<bool> channelIdIsAvailable(String id) async {
    var result = await _queryServices.idIsAvailable(IdIsAvailableReq()..id = id,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    return result.isAvailable;
  }

  getGroupMembers(Uid groupUid, int len) async {
    try {
      int i = 0;
      int membersSize = 0;

      bool finish = false;
      List<Member> members = [];
      while (i <= len || !finish) {
        var result = await mucServices.getGroupMembers(groupUid, 15, i);
        if (len == 0) membersSize = membersSize + result.members.length;
        for (MucPro.Member member in result.members) {
          try {
            members.add(await fetchMemberNameAndUsername(Member(
                mucUid: groupUid.asString(),
                memberUid: member.uid.asString(),
                role: getLocalRole(member.role))));
          } catch (e) {
            debug(e.toString());
          }
        }
        finish = result.finished;
        i = i + 15;
      }
      insertUserInDb(groupUid, members);
      if (len <= membersSize)
        _mucDao.upsertMucCompanion(MucsCompanion(
            uid: Value(groupUid.asString()), members: Value(membersSize)));
    } catch (e) {
      debug(e.toString());
    }
  }

  Future getGroupJointToken({Uid groupUid}) async {
    return await mucServices.getGroupJointToken(groupUid: groupUid);
  }

  Future getChannelJointToken({Uid channelUid}) async {
    return await mucServices.getChannelJointToken(channelUid: channelUid);
  }

  getChannelMembers(Uid channelUid, int len) async {
    try {
      int i = 0;
      int membersSize = 0;
      bool finish = false;
      List<Member> members = [];
      while (i <= len || !finish) {
        var result = await mucServices.getChannelMembers(channelUid, 15, i);
        if (len == 0) membersSize = membersSize + result.members.length;
        for (MucPro.Member member in result.members) {
          try {
            members.add(await fetchMemberNameAndUsername(Member(
                mucUid: channelUid.asString(),
                memberUid: member.uid.asString(),
                role: getLocalRole(member.role))));
          } catch (e) {
            debug(e.toString());
          }
        }

        finish = result.finished;
        i = i + 15;
        if (len <= membersSize)
          _mucDao.upsertMucCompanion(MucsCompanion(
              uid: Value(channelUid.asString()), members: Value(membersSize)));
      }
      insertUserInDb(channelUid, members);
    } catch (e) {
      debug(e.toString());
    }
  }

  Future<Member> fetchMemberNameAndUsername(Member member) async {
    var contact = await _contactRepo.getContact(member.memberUid.getUid());
    if (contact != null) {
      return member.copyWith(
          name: contact.firstName, username: contact.username);
    } else {
      var userInfo = await _uidIdNameDao.getByUid(member.memberUid);
      if (userInfo != null && userInfo.id != null)
        return member.copyWith(username: userInfo.id);
      else {
        var username =
            await _contactRepo.searchUserByUid(member.memberUid.getUid());
        if (username != null) return member.copyWith(username: username);
      }
    }
  }

  Future<String> fetchMucInfo(Uid mucUid) async {
    if (mucUid.category == Categories.GROUP) {
      MucPro.GetGroupRes group = await getGroupInfo(mucUid);
      if (group != null) {
        _mucDao.insertMuc(Muc(
          name: group.info.name,
          members: group.population.toInt(),
          uid: mucUid.asString(),
          info: group.info.info,
          token: group.token,
          pinMessagesId: getAsInt(group.pinMessages),
        ));

        getGroupMembers(mucUid, group.population.toInt());
        return group.info.name;
      }
    } else {
      GetChannelRes channel = await getChannelInfo(mucUid);
      if (channel != null) {
        _mucDao.insertMuc(Muc(
            name: channel.info.name,
            members: channel.population.toInt(),
            uid: mucUid.asString(),
            info: channel.info.info,
            token: channel.token,
            pinMessagesId: getAsInt(channel.pinMessages),
            id: channel.info.id));
        insertUserInDb(mucUid, [
          Member(
              memberUid: _accountRepo.currentUserUid.asString(),
              mucUid: mucUid.asString(),
              role: getLocalRole(channel.requesterRole))
        ]);
        if (channel.requesterRole != MucPro.Role.NONE)
          getChannelMembers(mucUid, channel.population.toInt());
        return channel.info.name;
      }
    }
  }

  // TODO there is bugs in delete member, where is memberUid ?!?!?
  Future<bool> removeGroup(Uid groupUid) async {
    var result = await mucServices.removeGroup(groupUid);
    if (result) {
      _mucDao.deleteMuc(groupUid.asString());
      _roomDao.updateRoom(RoomsCompanion(
          roomId: Value(groupUid.asString()), deleted: Value(true)));
      _memberDao.deleteAllMembers(groupUid.asString());
      _memberDao.deleteCurrentMucMember(groupUid.asString());
      return true;
    }
    return false;
  }

  Future<bool> removeChannel(Uid channelUid) async {
    var result = await mucServices.removeChannel(channelUid);
    if (result) {
      _mucDao.deleteMuc(channelUid.asString());
      _roomDao.updateRoom(RoomsCompanion(
          roomId: Value(channelUid.asString()), deleted: Value(true)));
      _memberDao.deleteCurrentMucMember(channelUid.asString());
      return true;
    }
    return false;
  }

  Future<MucPro.GetGroupRes> getGroupInfo(Uid groupUid) async {
    return await mucServices.getGroup(groupUid);
  }

  Future<GetChannelRes> getChannelInfo(Uid channelUid) async {
    return await mucServices.getChannel(channelUid);
  }

  changeGroupMemberRole(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = groupMember.memberUid.uid
      ..role = getRole(groupMember.role);
    bool result =
        await mucServices.changeGroupRole(member, groupMember.mucUid.uid);
    if (result) {
      _memberDao.insertMember(groupMember);
    }
  }

  changeChannelMemberRole(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = channelMember.memberUid.uid
      ..role = getRole(channelMember.role);
    var result =
        await mucServices.changeCahnnelRole(member, channelMember.mucUid.uid);
    if (result) {
      _memberDao.insertMember(channelMember);
    }
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    var result = await mucServices.leaveGroup(groupUid);
    if (result) {
      _mucDao.deleteMuc(groupUid.asString());
      _roomDao.updateRoom(RoomsCompanion(
          roomId: Value(groupUid.asString()), deleted: Value(true)));
      return true;
    }
    return false;
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    var result = await mucServices.leaveChannel(channelUid);
    if (result) {
      _mucDao.deleteMuc(channelUid.asString());
      _roomDao.updateRoom(RoomsCompanion(
          roomId: Value(channelUid.asString()), deleted: Value(true)));
      return true;
    }
    return false;
  }

  kickGroupMembers(List<Member> groupMember) async {
    List<MucPro.Member> members = List();
    for (Member member in groupMember) {
      members.add(MucPro.Member()
        ..uid = member.memberUid.uid
        ..role = getRole(member.role));
    }

    bool result =
        await mucServices.kickGroupMembers(members, groupMember[0].mucUid.uid);

    if (result) {
      for (Member member in groupMember) _memberDao.deleteMember(member);
    }
  }

  kickChannelMembers(List<Member> channelMember) async {
    List<MucPro.Member> members = List();
    for (Member member in channelMember) {
      members.add(MucPro.Member()
        ..uid = member.memberUid.uid
        ..role = getRole(member.role));
    }
    var result = await mucServices.kickChannelMembers(
        members, channelMember[0].mucUid.uid);
    if (result) {
      for (Member member in channelMember) _memberDao.deleteMember(member);
    }
  }

  banGroupMember(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = groupMember.memberUid.uid
      ..role = getRole(groupMember.role);
    await mucServices.banGroupMember(member, groupMember.mucUid.uid);
    //todo change database
  }

  banChannelMember(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = channelMember.memberUid.uid
      ..role = getRole(channelMember.role);
    await mucServices.unbanChannelMember(member, channelMember.mucUid.uid);
    //todo change database
  }

  unBanGroupMember(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = groupMember.memberUid.uid
      ..role = getRole(groupMember.role);
    await mucServices.banGroupMember(member, groupMember.mucUid.uid);
    //todo change databse
  }

  unBanChannelMember(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..uid = channelMember.memberUid.uid
      ..role = getRole(channelMember.role);
    await mucServices.unbanChannelMember(member, channelMember.mucUid.uid);
    //todo change database
  }

  joinGroup(Uid groupUid, String token) async {
    var result = await mucServices.joinGroup(groupUid, token);
    if (result) {
      fetchMucInfo(groupUid);
      return true;
    }
    return false;
  }

  joinChannel(Uid channelUid, String token) async {
    var result = await mucServices.joinChannel(channelUid, token);
    if (result) {
      fetchMucInfo(channelUid);
      return true;
    }
    return false;
  }

  modifyGroup(String mucId, String name, String info) async {
    var isSet = await mucServices.modifyGroup(
        MucPro.GroupInfo()
          ..name = name
          ..info = info,
        mucId.getUid());
    if (isSet) {
      _mucDao.upsertMucCompanion(MucsCompanion(
          uid: Value(mucId), name: Value(name), info: Value(info)));
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

    if (await mucServices.modifyChannel(channelInfo, mucUid.getUid())) {
      if (id.isEmpty) {
        _mucDao.upsertMucCompanion(MucsCompanion(
            uid: Value(mucUid), name: Value(name), info: Value(info)));
      } else {
        _mucDao.upsertMucCompanion(MucsCompanion(
            uid: Value(mucUid),
            name: Value(name),
            id: Value(id),
            info: Value(info)));
      }
    }
  }

  _insertToDb(Uid mucUid, String mucName, int memberCount, String info,
      {String channelId}) async {
    await _mucDao.insertMuc(Muc(
        uid: mucUid.asString(),
        name: mucName,
        info: info,
        members: memberCount,
        id: channelId ?? null));
    await _roomDao
        .insertRoomCompanion(RoomsCompanion.insert(roomId: mucUid.asString()));
  }

  Future<bool> sendMembers(Uid mucUid, List<Uid> memberUids) async {
    try {
      bool usersAdd = false;
      List<MucPro.Member> members = new List();
      for (Uid uid in memberUids) {
        members.add(MucPro.Member()
          ..uid = uid
          ..role = MucPro.Role.MEMBER);
      }

      if (mucUid.category == Categories.GROUP) {
        usersAdd = await mucServices.addGroupMembers(members, mucUid);
      } else {
        usersAdd = await mucServices.addChannelMembers(members, mucUid);
      }

      if (usersAdd) {
        if (mucUid.category == Categories.GROUP) {
          getGroupMembers(mucUid, members.length);
        } else {
          getChannelMembers(mucUid, members.length);
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
      await _memberDao.deleteAllMembers(mucUid.asString());
    }
    for (Member member in members) {
      _memberDao.insertMember(member);
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

  Future<List<int>> getPinMessages(String mucUid) async {
    var muc = await _mucDao.getMucByUid(mucUid);
    List pm = json.decode(muc.pinMessagesId);
    List<int> pinMessages = List();
    pm.forEach((element) {
      pinMessages.add(element as int);
    });
    return pinMessages;
  }

  String getAsInt(List<Int64> pinMessages) {
    String pm = "";
    pinMessages.forEach((element) {
      pm = "$pm , ${element.toString()} ,";
    });
    return pm;
  }
}
