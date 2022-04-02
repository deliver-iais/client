import 'package:fixnum/fixnum.dart';

import 'package:deliver/box/message.dart' as db;
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart'
    as channel_pb;
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';

import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart'
    as group_pb;
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:logger/logger.dart';

// TODO check timeout time again!!!!
class MucServices {
  final _logger = GetIt.I.get<Logger>();

  final groupServices = GetIt.I.get<group_pb.GroupServiceClient>();
  final channelServices = GetIt.I.get<channel_pb.ChannelServiceClient>();

  Future<Uid?> createNewGroup(String groupName, String info) async {
    try {
      var request =
          await groupServices.createGroup(group_pb.CreateGroupReq()
            ..name = groupName
            ..info = info);
      return request.uid;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addGroupMembers(List<Member> members, Uid groupUid,
      {bool retry = false}) async {
    group_pb.AddMembersReq addMemberRequest =
        group_pb.AddMembersReq();
    for (final member in members) {
      addMemberRequest.members.add(member);
    }
    addMemberRequest.group = groupUid;
    try {
      await groupServices.addMembers(addMemberRequest,
          options: CallOptions(timeout: const Duration(seconds: 6)));
      return true;
    } catch (e) {
      if (retry) {
        addGroupMembers(members, groupUid, retry: false);
        return true;
      } else {
        _logger.e(e);
        return false;
      }
    }
  }

  Future<group_pb.GetGroupRes?> getGroup(Uid groupUid) async {
    try {
      var request = await groupServices
          .getGroup(group_pb.GetGroupReq()..uid = groupUid);
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeGroup(Uid groupUid) async {
    try {
      await groupServices
          .removeGroup(group_pb.RemoveGroupReq()..uid = groupUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeGroupRole(Member member, Uid group) async {
    try {
      await groupServices.changeRole(group_pb.ChangeRoleReq()
        ..member = member
        ..group = group);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<group_pb.GetMembersRes> getGroupMembers(
      Uid groupUid, int limit, int pointer) async {
    var request = await groupServices.getMembers(group_pb.GetMembersReq()
      ..uid = groupUid
      ..pointer = pointer
      ..limit = limit);
    return request;
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    try {
      await groupServices
          .leaveGroup(group_pb.LeaveGroupReq()..group = groupUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> kickGroupMembers(List<Member> members, Uid groupUid) async {
    var kickMembersReq = group_pb.KickMembersReq();
    for (final member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq.group = groupUid;
    try {
      await groupServices.kickMembers(kickMembersReq);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> banGroupMember(Member member, Uid mucUid) async {
    try {
      await groupServices.banMember(group_pb.BanMemberReq()
        ..member = member.uid
        ..group = mucUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unbanGroupMember(Member member, Uid mucUid) async {
    try {
      await groupServices.unbanMember(group_pb.UnbanMemberReq()
        ..member = member.uid
        ..group = mucUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinGroup(Uid groupUid, String token) async {
    try {
      await groupServices.joinGroup(
          group_pb.JoinGroupReq()
            ..group = groupUid
            ..token = token,
          options: CallOptions(timeout: const Duration(seconds: 4)));
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> modifyGroup(group_pb.GroupInfo group, Uid mucUid) async {
    try {
      await groupServices.modifyGroup(group_pb.ModifyGroupReq()
        ..info = group
        ..uid = mucUid);
      return true;
    } catch (c) {
      return false;
    }
  }

  Future<Uid?> createNewChannel(
      String channelName, ChannelType type, String channelId, String info,
      {bool retry = true}) async {
    try {
      var request = await channelServices.createChannel(
          CreateChannelReq()
            ..name = channelName
            ..info = info
            ..type = type
            ..id = channelId,
          options: CallOptions(timeout: const Duration(seconds: 5)));
      return request.uid;
    } catch (e) {
      if (retry) {
        return createNewChannel(channelName, type, channelId, info,
            retry: false);
      } else {
        return null;
      }
    }
  }

  Future<bool> addChannelMembers(List<Member> members, Uid mucUid) async {
    try {
      channel_pb.AddMembersReq addMemberRequest =
          channel_pb.AddMembersReq();
      for (final member in members) {
        addMemberRequest.members.add(member);
      }
      addMemberRequest.channel = mucUid;
      await channelServices.addMembers(addMemberRequest);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<channel_pb.GetChannelRes?> getChannel(Uid channelUid) async {
    try {
      var request = await channelServices
          .getChannel(channel_pb.GetChannelReq()..uid = channelUid);
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeChannel(Uid channelUid) async {
    try {
      await channelServices
          .removeChannel(channel_pb.RemoveChannelReq()..uid = channelUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeCahnnelRole(Member member, Uid channel) async {
    try {
      await channelServices.changeRole(channel_pb.ChangeRoleReq()
        ..member = member
        ..channel = channel);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<channel_pb.GetMembersRes?> getChannelMembers(
      Uid channelUid, int limit, int pointer) async {
    try {
      var request =
          await channelServices.getMembers(channel_pb.GetMembersReq()
            ..uid = channelUid
            ..limit = limit
            ..pointer = pointer);
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    try {
      await channelServices.leaveChannel(
          channel_pb.LeaveChannelReq()..channel = channelUid);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> kickChannelMembers(List<Member> members, Uid channelUid) async {
    var kickMembersReq = channel_pb.KickMembersReq();
    for (final member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq.channel = channelUid;
    try {
      await channelServices.kickMembers(kickMembersReq);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> banChannelMember(Member member, Uid channelUid) async {
    try {
      await channelServices.banMember(channel_pb.BanMemberReq()
        ..member = member.uid
        ..channel = channelUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unbanChannelMember(Member member, Uid channelUid) async {
    try {
      await channelServices.unbanMember(channel_pb.UnbanMemberReq()
        ..member = member.uid
        ..channel = channelUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinChannel(Uid channelUid, String token) async {
    try {
      await channelServices.joinChannel(
          channel_pb.JoinChannelReq()
            ..channel = channelUid
            ..token,
          options: CallOptions(timeout: const Duration(seconds: 4)));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> modifyChannel(
      channel_pb.ChannelInfo channelInfo, Uid mucUid) async {
    try {
      await channelServices.modifyChannel(channel_pb.ModifyChannelReq()
        ..info = channelInfo
        ..uid = mucUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> pinMessage(db.Message message) async {
    try {
      if (message.roomUid.asUid().category == Categories.GROUP) {
        groupServices.pinMessage(group_pb.PinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!));
      } else {
        channelServices.pinMessage(channel_pb.PinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getGroupJointToken({required Uid groupUid}) async {
    try {
      var res = await groupServices.createToken(group_pb.CreateTokenReq()
        ..uid = groupUid
        ..validUntil = Int64(-1)
        ..numberOfAvailableJoins = Int64(-1));
      return res.joinToken;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getChannelJointToken({required Uid channelUid}) async {
    try {
      var res =
          await channelServices.createToken(channel_pb.CreateTokenReq()
            ..uid = channelUid
            ..validUntil = Int64(-1));
      return res.joinToken;
    } catch (e) {
      return null;
    }
  }

  Future<bool> unpinMessage(db.Message message) async {
    try {
      if (message.roomUid.asUid().category == Categories.GROUP) {
        groupServices.unpinMessage(group_pb.UnpinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!));
      } else {
        channelServices.unpinMessage(channel_pb.UnpinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!));
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
