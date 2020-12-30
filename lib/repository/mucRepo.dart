import 'dart:convert';

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
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucRepo {
  MucDao _mucDao = GetIt.I.get<MucDao>();
  MemberDao _memberDao = GetIt.I.get<MemberDao>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  var mucServices = GetIt.I.get<MucServices>();
  var accountRepo = GetIt.I.get<AccountRepo>();
  var messageDao = GetIt.I.get<MessageDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();

  Future<Uid> makeNewGroup(List<Uid> memberUids, String groupName) async {
    Uid groupUid = await mucServices.createNewGroup(groupName);
    if (groupUid != null) {
      sendMembers(groupUid, memberUids);
      _insertToDb(groupUid, groupName, memberUids.length + 1);
      return groupUid;
    }
    return null;
  }

  Future<Uid> makeNewChannel(String channelId, List<Uid> memberUids,
      String channelName, ChannelType channelType) async {
    Uid channelUid =
        await mucServices.createNewChannel(channelName, channelType, channelId);

    if (channelUid != null) {
      sendMembers(channelUid, memberUids);
      _insertToDb(channelUid, channelName, memberUids.length + 1);
      return channelUid;
    }
    return null;
  }

  getGroupMembers(Uid groupUid) async {
    try {
      var result = await mucServices.getGroupMembers(groupUid, 1, 1);
      List<Member> members = new List();
      for (MucPro.Member member in result) {
        members.add(await fetchMemberNameAndUsername(Member(
            mucUid: groupUid.asString(),
            memberUid: member.uid.asString(),
            role: getLocalRole(member.role))));
      }
      insertUserInDb(groupUid, members);
    } catch (e) {
      print(e.toString());
    }
  }

  getChannelMembers(Uid channelUid) async {
    try {
      var result = await mucServices.getChannelMembers(channelUid, 1, 1);
      List<Member> members = new List();
      for (MucPro.Member member in result) {
        members.add(await fetchMemberNameAndUsername(Member(
            mucUid: channelUid.asString(),
            memberUid: member.uid.asString(),
            role: getLocalRole(member.role))));
      }
      insertUserInDb(channelUid, members);
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
      var userAsContact =
          await _contactRepo.searchUserByUid(member.memberUid.getUid());
      if (userAsContact != null)
        return member.copyWith(username: userAsContact.username);
      else
        return member;
    }
  }

  // TODO remove later on if Add User to group message feature is implemented
  Future<String> fetchMucInfo(Uid mucUid) async {
    if (mucUid.category == Categories.GROUP) {
      MucPro.Group group = await getGroupInfo(mucUid);
      if (group != null)
        _mucDao.insertMuc(Muc(
            name: group.name,
            uid: mucUid.asString(),
            members: group.population.toInt()));
      getGroupMembers(mucUid);
      print(group.name);
      return group.name;
    } else {
      Channel channel = await getChannelInfo(mucUid);
      if (channel != null)
        _mucDao.insertMuc(Muc(
            name: channel.name,
            uid: mucUid.asString(),
            members: channel.population.toInt()));
      getChannelMembers(mucUid);
      return channel.name;
    }
  }

  // TODO there is bugs in delete member, where is memberUid ?!?!?
  Future<bool> removeGroup(Uid groupUid) async {
    var result = await mucServices.removeGroup(groupUid);
    if (result) {
      _mucDao.deleteMuc(groupUid.asString());
      _roomDao.deleteRoom(groupUid.asString());
      _memberDao.deleteAllMembers(groupUid.asString());
      return true;
    }
    return false;
  }

  Future<bool> removeChannel(Uid channelUid) async {
    var result = await mucServices.removeChannel(channelUid);
    if (result) {
      _mucDao.deleteMuc(channelUid.asString());
      _roomDao.deleteRoom(channelUid.asString());
      return true;
    }
    return false;
  }

  Future<MucPro.Group> getGroupInfo(Uid groupUid) async {
    return await mucServices.getGroup(groupUid);
  }

  Future<Channel> getChannelInfo(Uid channelUid) async {
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
      _roomDao.deleteRoom(groupUid.asString());
      return true;
    }
    return false;
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    var result = await mucServices.leaveChannel(channelUid);
    if (result) {
      _mucDao.deleteMuc(channelUid.asString());
      _roomDao.deleteRoom(channelUid.asString());
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
      MucPro.Group newGroup = await getGroupInfo(groupUid);
      getGroupMembers(groupUid);
      _mucDao.insertMuc(Muc(
          uid: groupUid.asString(), name: newGroup.name, info: newGroup.info));
    }
  }

  joinChannel(Uid channelUid) async {
    var result = await mucServices.joinChannel(channelUid);
    if (result) {
      Channel newChannel = await getChannelInfo(channelUid);
      getChannelMembers(channelUid);
      _mucDao.insertMuc(Muc(
          uid: channelUid.asString(),
          name: newChannel.name,
          info: newChannel.info));
    }
  }

  modifyGroup(Muc group) async {
    //todo is ......
    await mucServices.modifyGroup(MucPro.Group());
  }

  modifyChannel(Muc group) async {
    //todo is ......
    await mucServices.modifyGroup(MucPro.Group());
  }

  _insertToDb(Uid mucUid, String mucName, int memberCount) async {
    await _mucDao.insertMuc(
        Muc(uid: mucUid.asString(), name: mucName, members: memberCount));
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
          getGroupMembers(mucUid);
        } else {
          getChannelMembers(mucUid);
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
    _mucDao.updateMuc(mucUid.asString(), members.length);
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
    }
    throw Exception("Not Valid Role! $role");
  }
}
