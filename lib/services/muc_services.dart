import 'package:deliver/box/message.dart' as db;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/broadcast.pb.dart'
    as broadcast_pb;
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart'
    as channel_pb;
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart' as group_pb;
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

class MucServices {
  final _logger = GetIt.I.get<Logger>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _serVices = GetIt.I.get<ServicesDiscoveryRepo>();

  Future<Uid?> createNewGroup(String groupName, String info) async {
    try {
      final request = await _serVices.groupServiceClient.createGroup(
        group_pb.CreateGroupReq()
          ..name = groupName
          ..info = info,
      );
      return request.uid;
    } catch (e) {
      return null;
    }
  }

  Future<int> addGroupMembers(
    List<Member> members,
    Uid groupUid, {
    bool retry = false,
  }) async {
    final addMemberRequest = group_pb.AddMembersReq();
    for (final member in members) {
      addMemberRequest.members.add(member);
    }
    addMemberRequest.group = groupUid;
    try {
      await _serVices.groupServiceClient.addMembers(
        addMemberRequest,
        options: CallOptions(timeout: const Duration(seconds: 6)),
      );
      return StatusCode.ok;
    } on GrpcError catch (e) {
      if (retry) {
        return addGroupMembers(members, groupUid);
      } else {
        _logger.e(e);
        return e.code;
      }
    } catch (e) {
      _logger.e(e);
      return StatusCode.unknown;
    }
  }

  Future<int> addBroadcastMembers(
    List<Member> members,
    Uid broadcastUid, {
    bool retry = false,
  }) async {
    final addMemberRequest = broadcast_pb.AddMembersReq();
    for (final member in members) {
      addMemberRequest.members.add(member.uid);
    }
    addMemberRequest.broadcast = broadcastUid;
    try {
      await _serVices.broadcastServiceClient.addMembers(
        addMemberRequest,
        options: CallOptions(timeout: const Duration(seconds: 6)),
      );
      return StatusCode.ok;
    } on GrpcError catch (e) {
      if (retry) {
        return addBroadcastMembers(members, broadcastUid);
      } else {
        _logger.e(e);
        return e.code;
      }
    } catch (e) {
      _logger.e(e);
      return StatusCode.unknown;
    }
  }

  Future<group_pb.GetGroupRes?> getGroup(Uid groupUid) async {
    try {
      final request = await _serVices.groupServiceClient
          .getGroup(group_pb.GetGroupReq()..uid = groupUid);
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<broadcast_pb.GetBroadcastRes?> getBroadcast(Uid broadcastUid) async {
    try {
      final request = await _serVices.broadcastServiceClient
          .getBroadcast(broadcast_pb.GetBroadcastReq()..uid = broadcastUid);
      return request.copyWith((p0) {
        p0.population++;
      });
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeBroadcast(Uid broadcastUid) async {
    try {
      await _serVices.broadcastServiceClient.removeBroadcast(
        broadcast_pb.RemoveBroadcastReq()..uid = broadcastUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeGroup(Uid groupUid) async {
    try {
      await _serVices.groupServiceClient
          .removeGroup(group_pb.RemoveGroupReq()..uid = groupUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeGroupRole(Member member, Uid group) async {
    try {
      await _serVices.groupServiceClient.changeRole(
        group_pb.ChangeRoleReq()
          ..member = member
          ..group = group,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<(List<Member> members, bool finished)> getGroupMembers(
    Uid groupUid,
    int limit,
    int pointer,
  ) async {
    final request = await _serVices.groupServiceClient.getMembers(
      group_pb.GetMembersReq()
        ..uid = groupUid
        ..pointer = pointer
        ..limit = limit,
    );
    return (request.members, request.finished);
  }

  Future<bool> leaveGroup(Uid groupUid) async {
    try {
      await _serVices.groupServiceClient
          .leaveGroup(group_pb.LeaveGroupReq()..group = groupUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> kickGroupMembers(List<Member> members, Uid groupUid) async {
    final kickMembersReq = group_pb.KickMembersReq();
    for (final member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq.group = groupUid;
    try {
      await _serVices.groupServiceClient.kickMembers(kickMembersReq);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> banGroupMember(Member member, Uid mucUid) async {
    try {
      await _serVices.groupServiceClient.banMember(
        group_pb.BanMemberReq()
          ..member = member.uid
          ..group = mucUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unbanGroupMember(Member member, Uid mucUid) async {
    try {
      await _serVices.groupServiceClient.unbanMember(
        group_pb.UnbanMemberReq()
          ..member = member.uid
          ..group = mucUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinGroup(Uid groupUid, String token) async {
    try {
      await _serVices.groupServiceClient.joinGroup(
        group_pb.JoinGroupReq()
          ..group = groupUid
          ..token = token,
        options: CallOptions(timeout: const Duration(seconds: 4)),
      );
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> modifyGroup(group_pb.GroupInfo group, Uid mucUid) async {
    try {
      await _serVices.groupServiceClient.modifyGroup(
        group_pb.ModifyGroupReq()
          ..info = group
          ..uid = mucUid,
      );
      return true;
    } catch (c) {
      return false;
    }
  }

  Future<Uid?> createNewChannel(
    String channelName,
    ChannelType type,
    String channelId,
    String info, {
    bool retry = true,
  }) async {
    try {
      final request = await _serVices.channelServiceClient.createChannel(
        CreateChannelReq()
          ..name = channelName
          ..info = info
          ..type = type
          ..id = channelId,
        options: CallOptions(timeout: const Duration(seconds: 5)),
      );
      return request.uid;
    } catch (e) {
      if (retry) {
        return createNewChannel(
          channelName,
          type,
          channelId,
          info,
          retry: false,
        );
      } else {
        return null;
      }
    }
  }

  Future<Uid?> createNewBroadcast(
    String channelName,
    String info, {
    bool retry = true,
  }) async {
    try {
      final request = await _serVices.broadcastServiceClient.createBroadcast(
        broadcast_pb.CreateBroadcastReq()
          ..name = channelName
          ..info = info,
        options: CallOptions(timeout: const Duration(seconds: 5)),
      );
      return request.uid;
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return createNewBroadcast(
          channelName,
          info,
          retry: false,
        );
      } else {
        return null;
      }
    }
  }

  Future<int> addChannelMembers(List<Member> members, Uid mucUid) async {
    try {
      final addMemberRequest = channel_pb.AddMembersReq();
      for (final member in members) {
        addMemberRequest.members.add(member);
      }
      addMemberRequest.channel = mucUid;
      await _serVices.channelServiceClient.addMembers(addMemberRequest);
      return StatusCode.ok;
    } on GrpcError catch (e) {
      _logger.e(e);
      return e.code;
    } catch (e) {
      _logger.e(e);
      return StatusCode.unknown;
    }
  }

  Future<channel_pb.GetChannelRes?> getChannel(Uid channelUid) async {
    try {
      final request = await _serVices.channelServiceClient
          .getChannel(channel_pb.GetChannelReq()..uid = channelUid);
      return request;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeChannel(Uid channelUid) async {
    try {
      await _serVices.channelServiceClient
          .removeChannel(channel_pb.RemoveChannelReq()..uid = channelUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeCahnnelRole(Member member, Uid channel) async {
    try {
      await _serVices.channelServiceClient.changeRole(
        channel_pb.ChangeRoleReq()
          ..member = member
          ..channel = channel,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<(List<Member> members, bool finished)> getChannelMembers(
    Uid channelUid,
    int limit,
    int pointer,
  ) async {
    final request = await _serVices.channelServiceClient.getMembers(
      channel_pb.GetMembersReq()
        ..uid = channelUid
        ..limit = limit
        ..pointer = pointer,
    );
    return (request.members, request.finished);
  }

  Future<(List<Member> members, bool finished)> getBroadcastMembers(
    Uid mucUid,
    int limit,
    int pointer,
  ) async {
    final request = await _serVices.broadcastServiceClient.getMembers(
      broadcast_pb.GetMembersReq()
        ..uid = mucUid
        ..limit = limit
        ..pointer = pointer,
    );
    final memberList = request.members
        .map((e) => Member(uid: e, role: Role.NONE))
        .toList()
      ..add(Member(uid: _authRepo.currentUserUid, role: Role.OWNER));
    return (memberList, request.finished);
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    try {
      await _serVices.channelServiceClient
          .leaveChannel(channel_pb.LeaveChannelReq()..channel = channelUid);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> kickChannelMembers(List<Member> members, Uid channelUid) async {
    final kickMembersReq = channel_pb.KickMembersReq();
    for (final member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq.channel = channelUid;
    try {
      await _serVices.channelServiceClient.kickMembers(kickMembersReq);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> kickBroadcastMembers(
      List<Member> members, Uid broadcastUid,) async {
    final kickMembersReq = broadcast_pb.KickMembersReq();
    for (final member in members) {
      kickMembersReq.members.add(member.uid);
    }
    kickMembersReq.broadcast = broadcastUid;
    try {
      await _serVices.broadcastServiceClient.kickMembers(kickMembersReq);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> banChannelMember(Member member, Uid channelUid) async {
    try {
      await _serVices.channelServiceClient.banMember(
        channel_pb.BanMemberReq()
          ..member = member.uid
          ..channel = channelUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unbanChannelMember(Member member, Uid channelUid) async {
    try {
      await _serVices.channelServiceClient.unbanMember(
        channel_pb.UnbanMemberReq()
          ..member = member.uid
          ..channel = channelUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinChannel(Uid channelUid, String token) async {
    try {
      await _serVices.channelServiceClient.joinChannel(
        channel_pb.JoinChannelReq()
          ..channel = channelUid
          ..token,
        options: CallOptions(timeout: const Duration(seconds: 4)),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> modifyChannel(
    channel_pb.ChannelInfo channelInfo,
    Uid mucUid,
  ) async {
    try {
      await _serVices.channelServiceClient.modifyChannel(
        channel_pb.ModifyChannelReq()
          ..info = channelInfo
          ..uid = mucUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> modifyBroadcast(
    broadcast_pb.BroadcastInfo broadcastInfo,
    Uid mucUid,
  ) async {
    try {
      await _serVices.broadcastServiceClient.modifyBroadcast(
        broadcast_pb.ModifyBroadcastReq()
          ..info = broadcastInfo
          ..uid = mucUid,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> pinMessage(db.Message message) {
    if (message.roomUid.asUid().category == Categories.GROUP) {
      return _serVices.groupServiceClient.pinMessage(
        group_pb.PinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!),
      );
    } else {
      return _serVices.channelServiceClient.pinMessage(
        channel_pb.PinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!),
      );
    }
  }

  Future<String> getGroupJointToken({required Uid groupUid}) async {
    try {
      final res = await _serVices.groupServiceClient.createToken(
        group_pb.CreateTokenReq()
          ..uid = groupUid
          ..validUntil = Int64(-1)
          ..numberOfAvailableJoins = Int64(-1),
      );
      return res.joinToken;
    } catch (e) {
      return "";
    }
  }

  Future<void> deleteGroupJointToken({required Uid groupUid}) async {
    try {
      await _serVices.groupServiceClient.deleteToken(
        group_pb.DeleteTokenReq()..uid = groupUid,
      );
      return;
    } catch (e) {
      return;
    }
  }

  Future<String> getChannelJointToken({required Uid channelUid}) async {
    try {
      final res = await _serVices.channelServiceClient.createToken(
        channel_pb.CreateTokenReq()
          ..uid = channelUid
          ..validUntil = Int64(-1),
      );
      return res.joinToken;
    } catch (e) {
      return "";
    }
  }

  Future<void> deleteChannelJointToken({required Uid channelUid}) async {
    try {
      await _serVices.channelServiceClient.deleteToken(
        channel_pb.DeleteTokenReq()..uid = channelUid,
      );
      return;
    } catch (e) {
      return;
    }
  }

  Future<void> unpinMessage(db.Message message) {
    if (message.roomUid.asUid().category == Categories.GROUP) {
      return _serVices.groupServiceClient.unpinMessage(
        group_pb.UnpinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!),
      );
    } else {
      return _serVices.channelServiceClient.unpinMessage(
        channel_pb.UnpinMessageReq()
          ..uid = message.roomUid.asUid()
          ..messageId = Int64(message.id!),
      );
    }
  }
}
