import 'dart:convert';

import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/group.pb.dart' as MucPro;
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart' as MucPro;
import 'package:deliver_public_protocol/pub/v1/models/muc.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
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

  var _queryServices = GetIt.I.get<QueryServiceClient>();

  var _accountRepo = GetIt.I.get<AccountRepo>();

  Future<Uid> createNewGroup(List<Uid> memberUids, String groupName,String info) async {
    Uid groupUid = await mucServices.createNewGroup(groupName);
    if (groupUid != null) {
      sendMembers(groupUid, memberUids);
      _insertToDb(groupUid, groupName, memberUids.length + 1,info);
      return groupUid;
    }
    return null;
  }

  Future<Uid> createNewChannel(String channelId, List<Uid> memberUids,
      String channelName, ChannelType channelType,String info) async {
    Uid channelUid =
        await mucServices.createNewChannel(channelName, channelType, channelId);

    if (channelUid != null) {
      sendMembers(channelUid, memberUids);
      _memberDao.insertMember(Member(
          memberUid: _accountRepo.currentUserUid.asString(),
          mucUid: channelUid.asString(),
          role: MucRole.OWNER));
      _insertToDb(channelUid, channelName, memberUids.length + 1,info,
          channelId: channelId);
      fetchMucInfo(channelUid);
      return channelUid;
    }

    getChannelMembers(channelUid,memberUids.length);
    return null;
  }

  Future<bool> channelIdIsAvailable(String id) async {
    var result = await _queryServices.idIsAvailable(IdIsAvailableReq()..id = id,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    return result.isAvailable;
  }

  getGroupMembers(Uid groupUid,int len) async {
    try {
      int i=0;
      while(i<=len){
        var result = await mucServices.getGroupMembers(groupUid, 15, i);
        List<Member> members = new List();
        for (MucPro.Member member in result) {
          members.add(await fetchMemberNameAndUsername(Member(
              mucUid: groupUid.asString(),
              memberUid: member.uid.asString(),
              role: getLocalRole(member.role))));
        }
        insertUserInDb(groupUid, members);
        fetchMembersUserName(members);
        i = i+15;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getChannelMembers(Uid channelUid,int len) async {

    try {
      int i=0;
      while(i<= len){
        var result = await mucServices.getChannelMembers(channelUid, 15, i);
        List<Member> members = new List();
        for (MucPro.Member member in result) {
          members.add(await fetchMemberNameAndUsername(Member(
              mucUid: channelUid.asString(),
              memberUid: member.uid.asString(),
              role: getLocalRole(member.role))));
        }
        insertUserInDb(channelUid, members);
        i = i+15;
      }

    } catch (e) {
      print(e.toString());
    }
  }

  Future<Member> fetchMemberNameAndUsername(Member member) async {
    var contact = await _contactRepo.getContact(member.memberUid.getUid());
    if (contact != null) {
      return member.copyWith(
          name: contact.firstName, username: contact.username);
    } else {
      var username =
          await _contactRepo.searchUserByUid(member.memberUid.getUid());
      if (username != null)
        return member.copyWith(username: username);
      else
        return member;
    }
  }

  Future<String> fetchMucInfo(Uid mucUid) async {
    if (mucUid.category == Categories.GROUP) {
      MucPro.GetGroupRes group = await getGroupInfo(mucUid);
      if (group != null) {
        _mucDao.insertMuc(Muc(
          name: group.info.name,
          info: group.info.info,
          members: group.population.toInt(),
          uid: mucUid.asString(),
        ));

        getGroupMembers(mucUid,group.population.toInt());
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
            id: channel.info.id));
        insertUserInDb(mucUid, [
          Member(
              memberUid: _accountRepo.currentUserUid.asString(),
              mucUid: mucUid.asString(),
              role: getLocalRole(channel.requesterRole))
        ]);
        if (channel.requesterRole != MucPro.Role.NONE)
          getChannelMembers(mucUid,channel.population.toInt());
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

  joinGroup(Uid groupUid) async {
    var result = await mucServices.joinGroup(groupUid);
    if (result) {
      MucPro.GetGroupRes newGroup = await getGroupInfo(groupUid);
      getGroupMembers(groupUid,newGroup.population.toInt());
      _mucDao.insertMuc(Muc(
          uid: groupUid.asString(),
          name: newGroup.info.name,
          members: newGroup.population.toInt(),
          info: newGroup.info.info));
    }
  }

  joinChannel(Uid channelUid) async {
    var result = await mucServices.joinChannel(channelUid);
    if (result) {
      GetChannelRes newChannel = await getChannelInfo(channelUid);
      getChannelMembers(channelUid,newChannel.population.toInt());
      _mucDao.insertMuc(Muc(
          uid: channelUid.asString(),
          name: newChannel.info.name,
          members: newChannel.population.toInt(),
          id: newChannel.info.id,
          info: newChannel.info.info));
    }
  }

  modifyGroup(String mucId, String name) async {
    var isSet = await mucServices.modifyGroup(
        MucPro.GroupInfo()..name = name, mucId.getUid());
    if (isSet) {
      _mucDao.upsertMucCompanion(
          MucsCompanion(uid: Value(mucId), name: Value(name)));
    }
  }

  modifyChannel(String mucUid, String name, String id) async {
    ChannelInfo channelInfo;
    channelInfo = id.isEmpty ? (ChannelInfo()..name = name) : ChannelInfo()
      ..name = name
      ..id = id;
    if (await mucServices.modifyChannel(channelInfo, mucUid.getUid())) {
      if (id.isEmpty) {
        _mucDao.upsertMucCompanion(
            MucsCompanion(uid: Value(mucUid), name: Value(name)));
      } else {
        _mucDao.upsertMucCompanion(MucsCompanion(
            uid: Value(mucUid), name: Value(name), id: Value(id)));
      }
    }
  }

  _insertToDb(Uid mucUid, String mucName, int memberCount,String  info,
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
          getGroupMembers(mucUid,members.length);
        } else {
          getChannelMembers(mucUid,members.length);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  insertUserInDb(Uid mucUid, List<Member> members) {
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
    }
    throw Exception("Not Valid Role! $role");
  }

  void fetchMembersUserName(List<Member> members) async {
    for (var member in members) {
      var contact = await contactDao.getContactByUid(member.memberUid);
      if (contact != null)
        member = member.copyWith(
            name: contact.firstName, username: contact.username);
    }
    for (var member in members) {
      if (member.username == null) {
        var username =
            await _contactRepo.searchUserByUid(member.memberUid.getUid());
        member = member.copyWith(username: username);
      }
      _memberDao.insertMember(member);
    }
  }

  Stream<Member> checkJointToMuc({String roomUid}) {
    return _memberDao.isJoint(roomUid, _accountRepo.currentUserUid.asString());
  }
}
