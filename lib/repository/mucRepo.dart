import 'dart:convert';

import 'package:deliver_flutter/db/dao/GroupDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
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
  GroupDao _mucDao = GetIt.I.get<GroupDao>();
  MemberDao _memberDao = GetIt.I.get<MemberDao>();
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  RoomDao _roomDao = GetIt.I.get<RoomDao>();
  var mucServices = GetIt.I.get<MucServices>();
  var accountRepo = GetIt.I.get<AccountRepo>();
  var messageDao = GetIt.I.get<MessageDao>();
  var roomRepo = GetIt.I.get<RoomRepo>();

  Future<Uid> makeNewGroup(List<Uid> memberUids, String groupName) async {
    Uid groupUid = await mucServices.createNewGroup(groupName);
    if (groupUid != null) {
      sendMembers(groupUid, memberUids);
      _insetToDb(groupUid, groupName, memberUids.length + 1);
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
      _insetToDb(channelUid, channelName, memberUids.length + 1);
      return channelUid;
    }
    return null;
  }

  getGroupMembers(Uid groupUid) async {
    var result = await mucServices.getGroupMembers(groupUid, 1, 1);
    List<Member> members = new List();
    for (MucPro.Member member in result) {
      members.add(Member(
          memberUid: member.memberUid.string,
          mucUid: groupUid.string,
          role: getLocalRole(member.role)));
    }
    insertUserInDb(groupUid, members);
  }

  getChannelMembers(Uid channelUid) async {
    var result = await mucServices.getChnnelMembers(channelUid, 1, 1);
    List<Member> members = new List();
    for (MucPro.Member member in result) {
      members.add(Member(
          memberUid: member.memberUid.string,
          mucUid: channelUid.string,
          role: getLocalRole(member.role)));
    }
    insertUserInDb(channelUid, members);
  }

  Future<bool> removeGroup(Uid groupUid) async {
    var result = await mucServices.removeGroup(groupUid);
    if (result) {
      _mucDao.deleteMuc(Muc(uid: groupUid.string));
      _roomDao.deleteRoom(Room(roomId: groupUid.string));
      _memberDao.deleteMember(Member(mucUid: groupUid.string));
      return true;
    }
    return false;
  }

  Future<bool> removeChannel(Uid channelUid) async {
    var result = await mucServices.removeChannel(channelUid);
    if (result) {
      _mucDao.deleteMuc(channelUid.string);
      _roomDao.deleteRoom(Room(roomId: channelUid.string));
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
      ..mucUid = groupMember.mucUid.uid
      ..memberUid = groupMember.memberUid.uid
      ..role = getRole(groupMember.role);
    bool result = await mucServices.changeGroupRole(member);
    if (result) {
      _memberDao.insertMember(groupMember);
    }
  }

  changeChannelMemberRole(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..mucUid = channelMember.mucUid.uid
      ..memberUid = channelMember.memberUid.uid
      ..role = getRole(channelMember.role);
    var result = await mucServices.changeGroupRole(member);

    if (result) {
      _memberDao.insertMember(channelMember);
    }
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    var result = await mucServices.leaveGroup(groupUid);
    if (result) {
      _mucDao.deleteMuc(Muc(uid: groupUid.string));
      _roomDao.deleteRoom(Room(roomId: groupUid.string));
      return true;
    }
    return false;
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    var result = await mucServices.leaveChannel(channelUid);
    if (result) {
      _mucDao.deleteMuc(Muc(uid: channelUid.string));
      _roomDao.deleteRoom(Room(roomId: channelUid.string));
      return true;
    }
    return false;
  }

  kickGroupMembers(List<Member> groupMember) async {
    List<MucPro.Member> members = List();
    for (Member member in groupMember) {
      members.add(MucPro.Member()
        ..mucUid = member.mucUid.uid
        ..memberUid = member.memberUid.uid
        ..role = getRole(member.role));
    }

    bool result = await mucServices.kickGroupMembers(members);

    if (result) {
      for (Member member in groupMember) _memberDao.deleteMember(member);
    }
  }

  kickChannelMembers(List<Member> channelMember) async {
    List<MucPro.Member> members = List();
    for (Member member in channelMember) {
      members.add(MucPro.Member()
        ..mucUid = member.mucUid.uid
        ..memberUid = member.memberUid.uid
        ..role = getRole(member.role));
    }
    var result = await mucServices.kickChannelMembers(members);
    if (result) {
      for (Member member in channelMember) _memberDao.deleteMember(member);
    }
  }

  banGroupMember(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..mucUid = groupMember.mucUid.uid
      ..memberUid = groupMember.memberUid.uid
      ..role = getRole(groupMember.role);
    var result = await mucServices.banGroupMember(member);
    //todo change databse
  }

  banChannelMember(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..mucUid = channelMember.mucUid.uid
      ..memberUid = channelMember.memberUid.uid
      ..role = getRole(channelMember.role);
    var result = await mucServices.unbanChannelMember(member);
    //todo change databse
  }

  unBanGroupMember(Member groupMember) async {
    MucPro.Member member = MucPro.Member()
      ..mucUid = groupMember.mucUid.uid
      ..memberUid = groupMember.memberUid.uid
      ..role = getRole(groupMember.role);
    var result = await mucServices.banGroupMember(member);
    //todo change databse
  }

  unBanChannelMember(Member channelMember) async {
    MucPro.Member member = MucPro.Member()
      ..mucUid = channelMember.mucUid.uid
      ..memberUid = channelMember.memberUid.uid
      ..role = getRole(channelMember.role);
    var result = await mucServices.unbanChannelMember(member);
    //todo change databse
  }

  joinGroup(Uid groupUid) async {
    var result = await mucServices.joinGroup(groupUid);
    if (result) {
      MucPro.Group newGroup = await getGroupInfo(groupUid);
      getGroupMembers(groupUid);
      _mucDao.insertMuc(
          Muc(uid: groupUid.string, name: newGroup.name, info: newGroup.info));
    }
  }

  joinChannel(Uid channelUid) async {
    var result = await mucServices.joinChannel(channelUid);
    if (result) {
      Channel newChannel = await getChannelInfo(channelUid);
      getChannelMembers(channelUid);
      _mucDao.insertMuc(Muc(
          uid: channelUid.string,
          name: newChannel.name,
          info: newChannel.info));
    }
  }

  modifyGroup(Muc group) async {
    //todo is ......
    var result = await mucServices.modifyGroup(MucPro.Group());
  }

  modifyChannel(Muc group) async {
    //todo is ......
    var result = await mucServices.modifyGroup(MucPro.Group());
  }

  _insetToDb(Uid mucUid, String mucName, int memberCount) async {
    await _mucDao.insertMuc(
        Muc(uid: mucUid.string, name: mucName, members: memberCount));
    roomRepo.updateRoomName(mucUid, mucName);
    Room room = Room(roomId: mucUid.string, mute: false);
    await _roomDao.insertRoom(room);
    sendFirstMessage(mucUid, room);
  }

  sendFirstMessage(Uid groupUid, Room room) async {
    var message = Message(
        roomId: groupUid.string,
        packetId: _getPacketId(),
        time: DateTime.now(),
        from: _accountRepo.currentUserUid.string,
        to: groupUid.string,
        type: MessageType.PERSISTENT_EVENT,
        json: groupUid.category == Categories.GROUP
            ? jsonEncode({"text": "You created the group"})
            : jsonEncode({"text": "You created the channel"}));
    var dbId = await messageDao.insertMessage(message);
    await _roomDao.updateRoom(room.copyWith(lastMessageDbId: dbId));
  }

  Future<bool> sendMembers(Uid mucUid, List<Uid> memberUids) async {
    try {
      bool usersAdd = false;
      List<MucPro.Member> members = new List();
      for (Uid uid in memberUids) {
        members.add(MucPro.Member()
          ..memberUid = uid
          ..mucUid = mucUid
          ..role = MucPro.Role.MEMBER);
      }

      if (mucUid.category == Categories.GROUP) {
        usersAdd = await mucServices.addGroupMembers(members);
      } else {
        usersAdd = await mucServices.addChannelMembers(members);
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
    _mucDao.insertMuc(Muc(uid: mucUid.string, members: members.length));
  }

  String _getPacketId() {
    return "${_accountRepo.currentUserUid}:${DateTime.now().microsecondsSinceEpoch}";
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
  }
}
