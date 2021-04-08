import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart'
    as ChannelServices;
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';

import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart'
    as GroupServices;
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class MucServices {
  var _accountRepo = GetIt.I.get<AccountRepo>();

  var groupServices =
      GroupServices.GroupServiceClient(MucServicesClientChannel);
  var channelServices =
      ChannelServices.ChannelServiceClient(MucServicesClientChannel);

  Future<Uid> createNewGroup(String groupName) async {
    try {
      var request = await groupServices.createGroup(
          GroupServices.CreateGroupReq()..name = groupName,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return request.uid;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addGroupMembers(List<Member> members, Uid groupUid) async {
    GroupServices.AddMembersReq addMemberRequest =
        GroupServices.AddMembersReq();
    for (Member member in members) {
      addMemberRequest.members.add(member);
    }
    addMemberRequest..group = groupUid;
    try {
      await groupServices.addMembers(addMemberRequest,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<GroupServices.GetGroupRes> getGroup(Uid groupUid) async {
    try {
      var request = await groupServices.getGroup(
          GroupServices.GetGroupReq()..uid = groupUid,
          options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()},
            timeout: Duration(seconds: 2),
          ));
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeGroup(Uid groupUid) async {
    try {
      await groupServices.removeGroup(
          GroupServices.RemoveGroupReq()..uid = groupUid,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeGroupRole(Member member, Uid group) async {
    try {
      await groupServices.changeRole(
          GroupServices.ChangeRoleReq()
            ..member = member
            ..group = group,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Member>> getGroupMembers(
      Uid groupUid, int limit, int pointer) async {
    var request = await groupServices.getMembers(
        GroupServices.GetMembersReq()
          ..uid = groupUid
          ..pointer = pointer
          ..limit = limit,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    return request.members;
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    try {
      await groupServices.leaveGroup(
          GroupServices.LeaveGroupReq()..group = groupUid,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> kickGroupMembers(List<Member> members, Uid groupUid) async {
    var kickMembersReq = GroupServices.KickMembersReq();
    for (Member member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq.group = groupUid;
    try {
      await groupServices.kickMembers(kickMembersReq,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> banGroupMember(Member member, Uid mucUid) async {
    try {
      await groupServices.banMember(
          GroupServices.BanMemberReq()
            ..member = member.uid
            ..group = mucUid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unbanGroupMember(Member member, Uid mucUid) async {
    try {
      await groupServices.unbanMember(
          GroupServices.UnbanMemberReq()
            ..member = member.uid
            ..group = mucUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getPermissionToken(Uid uid) async {
    if (uid.category == Categories.GROUP) {
      var res = await groupServices.getPermission(
          GroupServices.GetPermissionReq()
            ..group = uid
            ..accessField = AccessField.CHANGE_AVATAR,
          options: CallOptions(
              metadata: {"access_token": await _accountRepo.getAccessToken()}));
      return res.token;
    } else {
      var res = await channelServices.getPermission(
          GetPermissionReq()
            ..channel = uid
            ..accessField = AccessField.CHANGE_AVATAR,
          options: CallOptions(
              metadata: {"access_token": await _accountRepo.getAccessToken()}));
      return res.token;
    }
  }

  Future<bool> joinGroup(Uid groupUid) async {
    try {
      await groupServices.joinGroup(
          GroupServices.JoinGroupReq()..group = groupUid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> modifyGroup(GroupServices.GroupInfo group, Uid mucUid) async {
    try {
      await groupServices.modifyGroup(
          GroupServices.ModifyGroupReq()
            ..info = group
            ..uid = mucUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (c) {
      return false;
    }
  }

  Future<Uid> createNewChannel(
      String channelName, ChannelType type, String channelId) async {
    try {
      var request = await channelServices.createChannel(
          CreateChannelReq()
            ..name = channelName
            ..type = type
            ..id = channelId,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return request.uid;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addChannelMembers(List<Member> members, Uid mucUid) async {
    try {
      ChannelServices.AddMembersReq addMemberRequest =
          ChannelServices.AddMembersReq();
      for (Member member in members) {
        addMemberRequest.members.add(member);
      }
      addMemberRequest..channel = mucUid;
      await channelServices.addMembers(addMemberRequest,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<ChannelServices.GetChannelRes> getChannel(Uid channelUid) async {
    try {
      var request = await channelServices.getChannel(
          ChannelServices.GetChannelReq()..uid = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeChannel(Uid channelUid) async {
    try {
      await channelServices.removeChannel(
          ChannelServices.RemoveChannelReq()..uid = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeCahnnelRole(Member member, Uid channel) async {
    try {
      await channelServices.changeRole(
          ChannelServices.ChangeRoleReq()
            ..member = member
            ..channel = channel,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Member>> getChannelMembers(
      Uid channelUid, int limit, int pointer) async {
    try {
      var request = await channelServices.getMembers(
          ChannelServices.GetMembersReq()
            ..uid = channelUid
            ..limit = limit
            ..pointer = pointer,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return request.members;
    } catch (e) {
      return null;
    }
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    try {
      await channelServices.leaveChannel(
          ChannelServices.LeaveChannelReq()..channel = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> kickChannelMembers(List<Member> members, Uid channelUid) async {
    var kickMembersReq = ChannelServices.KickMembersReq();
    for (Member member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq..channel = channelUid;
    try {
      await channelServices.kickMembers(kickMembersReq,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> banChannelMember(Member member, Uid channelUid) async {
    try {
      await channelServices.banMember(
          ChannelServices.BanMemberReq()
            ..member = member.uid
            ..channel = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unbanChannelMember(Member member, Uid channelUid) async {
    try {
      await channelServices.unbanMember(
          ChannelServices.UnbanMemberReq()
            ..member = member.uid
            ..channel = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinChannel(Uid channelUid) async {
    try {
      await channelServices.joinChannel(
          ChannelServices.JoinChannelReq()..channel = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> modifyChannel(
      ChannelServices.ChannelInfo channelInfo, Uid mucUid) async {
    try {
      await channelServices.modifyChannel(
          ChannelServices.ModifyChannelReq()
            ..info = channelInfo
            ..uid = mucUid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }
}
