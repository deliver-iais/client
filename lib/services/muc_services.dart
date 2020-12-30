import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart'
    as ChannelServices;
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';

import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart'
    as GroupServices;
import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart';

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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<GroupServices.Group> getGroup(Uid groupUid) async {
    try {
      var request = await groupServices.getGroup(
          GroupServices.GetGroupReq()..uid = groupUid,
          options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()},
            timeout: Duration(seconds: 2),
          ));
      return request.group;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeGroup(Uid groupUid) async {
    try {
      await groupServices.removeGroup(
          GroupServices.RemoveGroupReq()..uid = groupUid,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Member>> getGroupMembers(
      Uid groupUid, int limit, int pointer) async {
    var request = await groupServices.getMembers(
        GroupServices.GetMembersReq()..uid = groupUid,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    return request.members;
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    try {
      await groupServices.leaveGroup(
          GroupServices.LeaveGroupReq()..group = groupUid,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinGroup(Uid groupUid) async {
    try {
      await groupServices.joinGroup(
          GroupServices.JoinGroupReq()..group = groupUid,
          options: CallOptions(
              timeout: Duration(seconds: 1),
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future modifyGroup(Group group) async {
    await groupServices.modifyGroup(
        GroupServices.ModifyGroupReq()..group = group,
        options: CallOptions(
            timeout: Duration(seconds: 1),
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<ChannelServices.Channel> getChannel(Uid channelUid) async {
    try {
      var request = await channelServices.getChannel(
          ChannelServices.GetChannelReq()..uid = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return request.channel;
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Member>> getChannelMembers(
      Uid channelUid, int limit, int pointer) async {
    try {
      var request = await channelServices.getMembers(
          ChannelServices.GetMembersReq()..uid = channelUid,
          options: CallOptions(
              timeout: Duration(seconds: 2),
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
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
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future modifyChannel(ChannelServices.Channel channel) async {
    await channelServices.modifyChannel(
        ChannelServices.ModifyChannelReq()..channel = channel,
        options: CallOptions(
            timeout: Duration(seconds: 1),
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
  }
}
