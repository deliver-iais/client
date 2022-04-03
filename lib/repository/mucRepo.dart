// ignore_for_file: file_names

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/group.pb.dart' as group_pb;
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart' as muc_pb;
import 'package:deliver_public_protocol/pub/v1/models/muc.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class MucRepo {
  final _logger = GetIt.I.get<Logger>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _queryServices = GetIt.I.get<QueryServiceClient>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  Future<Uid?> createNewGroup(
    List<Uid> memberUids,
    String groupName,
    String info,
  ) async {
    final groupUid = await _mucServices.createNewGroup(groupName, info);
    if (groupUid != null) {
      sendMembers(groupUid, memberUids);
      _insertToDb(groupUid, groupName, memberUids.length + 1, info);
      return groupUid;
    }
    return null;
  }

  Future<Uid?> createNewChannel(
    String channelId,
    List<Uid> memberUids,
    String channelName,
    ChannelType channelType,
    String info,
  ) async {
    final channelUid = await _mucServices.createNewChannel(
      channelName,
      channelType,
      channelId,
      info,
    );

    if (channelUid != null) {
      sendMembers(channelUid, memberUids);
      _mucDao.saveMember(
        Member(
          memberUid: _authRepo.currentUserUid.asString(),
          mucUid: channelUid.asString(),
          role: MucRole.OWNER,
        ),
      );
      _insertToDb(
        channelUid,
        channelName,
        memberUids.length + 1,
        info,
        channelId: channelId,
      );
      fetchMucInfo(channelUid);
      fetchChannelMembers(channelUid, memberUids.length);
      return channelUid;
    }

    return null;
  }

  Future<bool> channelIdIsAvailable(String id) async {
    final result =
        await _queryServices.idIsAvailable(IdIsAvailableReq()..id = id);
    return result.isAvailable;
  }

  Future<void> fetchGroupMembers(Uid groupUid, int len) async {
    try {
      var i = 0;
      var membersSize = 0;

      var finish = false;
      final members = <Member>[];
      while (i <= len || !finish) {
        final result = await _mucServices.getGroupMembers(groupUid, 15, i);
        membersSize = membersSize + result.members.length;
        for (final member in result.members) {
          try {
            members.add(
              Member(
                mucUid: groupUid.asString(),
                memberUid: member.uid.asString(),
                role: getLocalRole(member.role),
              ),
            );
          } catch (e) {
            _logger.e(e);
          }
        }
        finish = result.finished;
        i = i + 15;
      }
      insertUserInDb(groupUid, members);
      if (len <= membersSize) {
        _mucDao.update(Muc(uid: groupUid.asString(), population: membersSize));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<String?> getGroupJointToken({required Uid groupUid}) async =>
      _mucServices.getGroupJointToken(groupUid: groupUid);

  Future<String?> getChannelJointToken({required Uid channelUid}) async =>
      _mucServices.getChannelJointToken(channelUid: channelUid);

  Future<void> fetchChannelMembers(Uid channelUid, int len) async {
    try {
      var i = 0;
      var membersSize = 0;
      var finish = false;
      final members = <Member>[];
      while (i <= len || !finish) {
        final result = await _mucServices.getChannelMembers(channelUid, 15, i);
        if (result != null) {
          membersSize = membersSize + result.members.length;
          for (final member in result.members) {
            try {
              members.add(
                Member(
                  mucUid: channelUid.asString(),
                  memberUid: member.uid.asString(),
                  role: getLocalRole(member.role),
                ),
              );
            } catch (e) {
              _logger.e(e);
            }
          }

          finish = result.finished;
          i = i + 15;
          if (len <= membersSize) {
            _mucDao.update(
              Muc(uid: channelUid.asString(), population: membersSize),
            );
          }
        }
      }
      insertUserInDb(channelUid, members);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<Muc?> fetchMucInfo(Uid mucUid) async {
    if (mucUid.category == Categories.GROUP) {
      final group = await _mucServices.getGroup(mucUid);
      final m = await _mucDao.get(mucUid.asString());
      if (group != null) {
        final muc = Muc(
          name: group.info.name,
          population: group.population.toInt(),
          uid: mucUid.asString(),
          info: group.info.info,
          token: group.token,
          showPinMessage: m != null ? m.showPinMessage : true,
          lastMessageId: group.lastMessageId.toInt(),
          pinMessagesIdList: group.pinMessages.map((e) => e.toInt()).toList(),
        );

        _mucDao.save(muc);

        fetchGroupMembers(mucUid, group.population.toInt());
        if (m != null) {
          _checkShowPin(mucUid, group.pinMessages, m.pinMessagesIdList ?? []);
        }
        return muc;
      }
      return null;
    } else {
      final channel = await getChannelInfo(mucUid);
      final c = await _mucDao.get(mucUid.asString());
      if (channel != null) {
        final muc = Muc(
          name: channel.info.name,
          population: channel.population.toInt(),
          uid: mucUid.asString(),
          lastMessageId: channel.lastMessageId.toInt(),
          info: channel.info.info,
          token: channel.token,
          showPinMessage: c != null ? c.showPinMessage : true,
          pinMessagesIdList: channel.pinMessages.map((e) => e.toInt()).toList(),
          id: channel.info.id,
        );

        _mucDao.save(muc);
        if (c != null) {
          _checkShowPin(mucUid, channel.pinMessages, c.pinMessagesIdList ?? []);
        }
        // ignore: unrelated_type_equality_checks
        if (channel.requesterRole != muc_pb.Role.NONE &&
            channel.requesterRole != muc_pb.Role.MEMBER) {
          fetchChannelMembers(mucUid, channel.population.toInt());
        }
        return muc;
      }
      return null;
    }
  }

  Future<bool> isMucAdminOrOwner(String memberUid, String mucUid) async {
    final member = await _mucDao.getMember(memberUid, mucUid);
    if (member == null) return false;
    if (member.role == MucRole.OWNER || member.role == MucRole.ADMIN) {
      return true;
    } else if (mucUid.asUid().category == Categories.CHANNEL) {
      final res = await getChannelInfo(mucUid.asUid());
      if (res != null) {
        return res.requesterRole == Role.ADMIN ||
            res.requesterRole == Role.OWNER;
      }
      return false;
    }
    return false;
  }

  Future<bool> isMucOwner(String userUid, String mucUid) async {
    final member = await _mucDao.getMember(userUid, mucUid);
    if (member != null) {
      if (member.role == MucRole.OWNER) {
        return true;
      }
    }
    return false;
  }

  Future<void> updateMuc(Muc muc) => _mucDao.update(muc);

  Future<List<Member>> searchMemberByNameOrId(String mucUid) async => [];

  Future<List<Member?>> getAllMembers(String mucUid) =>
      _mucDao.getAllMembers(mucUid);

  Stream<List<Member?>> watchAllMembers(String mucUid) =>
      _mucDao.watchAllMembers(mucUid);

  Future<Muc?> getMuc(String mucUid) => _mucDao.get(mucUid);

  Stream<Muc?> watchMuc(String mucUid) => _mucDao.watch(mucUid);

  Future<bool> removeMuc(Uid mucUid) {
    if (mucUid.isGroup()) {
      return _removeGroup(mucUid);
    } else if (mucUid.isChannel()) {
      return _removeChannel(mucUid);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> _removeGroup(Uid groupUid) async {
    final result = await _mucServices.removeGroup(groupUid);
    if (result) {
      _mucDao.delete(groupUid.asString());
      _roomDao.updateRoom(Room(uid: groupUid.asString(), deleted: true));
      _mucDao.deleteAllMembers(groupUid.asString());
      return true;
    }
    return false;
  }

  Future<bool> _removeChannel(Uid channelUid) async {
    final result = await _mucServices.removeChannel(channelUid);
    if (result) {
      _mucDao.delete(channelUid.asString());
      _roomDao.updateRoom(Room(uid: channelUid.asString(), deleted: true));
      _mucDao.deleteAllMembers(channelUid.asString());
      return true;
    }
    return false;
  }

  Future<GetChannelRes?> getChannelInfo(Uid channelUid) async =>
      _mucServices.getChannel(channelUid);

  Future<void> changeGroupMemberRole(Member groupMember) async {
    final member = muc_pb.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    final result =
        await _mucServices.changeGroupRole(member, groupMember.mucUid.asUid());
    if (result) {
      _mucDao.saveMember(groupMember);
    }
  }

  Future<void> changeChannelMemberRole(Member channelMember) async {
    final member = muc_pb.Member()
      ..uid = channelMember.memberUid.asUid()
      ..role = getRole(channelMember.role);
    final result = await _mucServices.changeCahnnelRole(
      member,
      channelMember.mucUid.asUid(),
    );
    if (result) {
      _mucDao.saveMember(channelMember);
    }
  }

  Future<bool> leaveMuc(Uid mucUid) {
    if (mucUid.isGroup()) {
      return _leaveGroup(mucUid);
    } else if (mucUid.isChannel()) {
      return _leaveChannel(mucUid);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> _leaveGroup(Uid groupUid) async {
    final result = await _mucServices.leaveGroup(groupUid);
    if (result) {
      _mucDao.delete(groupUid.asString());
      _roomDao.updateRoom(Room(uid: groupUid.asString(), deleted: true));
      return true;
    }
    return false;
  }

  Future<bool> _leaveChannel(Uid channelUid) async {
    final result = await _mucServices.leaveChannel(channelUid);
    if (result) {
      _mucDao.delete(channelUid.asString());
      _roomDao.updateRoom(Room(uid: channelUid.asString(), deleted: true));
      return true;
    }
    return false;
  }

  Future<bool> kickGroupMembers(List<Member> groupMembers) async {
    if (groupMembers.isEmpty) {
      return false;
    }

    final members = groupMembers
        .map(
          (m) => muc_pb.Member()
            ..uid = m.memberUid.asUid()
            ..role = getRole(m.role),
        )
        .toList();

    final result = await _mucServices.kickGroupMembers(
      members,
      groupMembers[0].mucUid.asUid(),
    );

    if (result) {
      for (final member in groupMembers) {
        _mucDao.deleteMember(member);
      }
      return true;
    }
    return false;
  }

  Future<bool> kickChannelMembers(List<Member> channelMembers) async {
    final members = channelMembers
        .map(
          (m) => muc_pb.Member()
            ..uid = m.memberUid.asUid()
            ..role = getRole(m.role),
        )
        .toList();
    final result = await _mucServices.kickChannelMembers(
      members,
      channelMembers[0].mucUid.asUid(),
    );
    if (result) {
      for (final member in channelMembers) {
        _mucDao.deleteMember(member);
      }
      return true;
    }

    return false;
  }

  Future<void> banGroupMember(Member groupMember) async {
    final member = muc_pb.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    if (await _mucServices
        .kickGroupMembers([member], groupMember.mucUid.asUid())) {
      if (await _mucServices.banGroupMember(
        member,
        groupMember.mucUid.asUid(),
      )) {
        _mucDao.deleteMember(groupMember);
      }
    }
  }

  Future<void> banChannelMember(Member channelMember) async {
    final member = muc_pb.Member()
      ..uid = channelMember.memberUid.asUid()
      ..role = getRole(channelMember.role);
    if (await _mucServices
        .kickChannelMembers([member], channelMember.mucUid.asUid())) {
      if (await _mucServices.banChannelMember(
        member,
        channelMember.mucUid.asUid(),
      )) {
        _mucDao.deleteMember(channelMember);
      }
    }
  }

  Future<void> unBanGroupMember(Member groupMember) async {
    final member = muc_pb.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    await _mucServices.banGroupMember(member, groupMember.mucUid.asUid());
    //todo change database
  }

  Future<void> unBanChannelMember(Member channelMember) async {
    final member = muc_pb.Member()
      ..uid = channelMember.memberUid.asUid()
      ..role = getRole(channelMember.role);
    await _mucServices.unbanChannelMember(member, channelMember.mucUid.asUid());
    //todo change database
  }

  Future<Muc?> joinGroup(Uid groupUid, String token) async {
    final result = await _mucServices.joinGroup(groupUid, token);
    if (result) {
      return fetchMucInfo(groupUid);
    }
    return null;
  }

  Future<Muc?> joinChannel(Uid channelUid, String token) async {
    final result = await _mucServices.joinChannel(channelUid, token);
    if (result) {
      return fetchMucInfo(channelUid);
    }
    return null;
  }

  Future<void> modifyGroup(String mucId, String name, String info) async {
    final isSet = await _mucServices.modifyGroup(
      group_pb.GroupInfo()
        ..name = name
        ..info = info,
      mucId.asUid(),
    );
    if (isSet) {
      _mucDao.update(Muc(uid: mucId, name: name, info: info));
    }
  }

  Future<void> modifyChannel(
    String mucUid,
    String name,
    String id,
    String info,
  ) async {
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

  Future<void> _insertToDb(
    Uid mucUid,
    String mucName,
    int memberCount,
    String info, {
    String? channelId,
  }) async {
    await _mucDao.save(
      Muc(
        uid: mucUid.asString(),
        name: mucName,
        info: info,
        population: memberCount,
        id: channelId,
      ),
    );
    await _roomDao.updateRoom(Room(uid: mucUid.asString()));
  }

  Future<bool> sendMembers(Uid mucUid, List<Uid> memberUids) async {
    try {
      var usersAdd = false;
      final members = <muc_pb.Member>[];
      for (final uid in memberUids) {
        members.add(
          muc_pb.Member()
            ..uid = uid
            ..role = mucUid.isChannel() ? muc_pb.Role.NONE : muc_pb.Role.MEMBER,
        );
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
      _logger.e(e);
      return false;
    }
  }

  Future<void> insertUserInDb(Uid mucUid, List<Member> members) async {
    if (members.isNotEmpty) {
      await _mucDao.deleteAllMembers(mucUid.asString());
    }
    for (final member in members) {
      _mucDao.saveMember(member);
      _contactRepo.fetchMemberId(member);
    }
  }

  muc_pb.Role getRole(MucRole role) {
    switch (role) {
      case MucRole.MEMBER:
        return muc_pb.Role.MEMBER;
      case MucRole.ADMIN:
        return muc_pb.Role.ADMIN;
      case MucRole.OWNER:
        return muc_pb.Role.OWNER;
      case MucRole.NONE:
        return muc_pb.Role.NONE;
    }
  }

  MucRole getLocalRole(Role role) {
    switch (role) {
      case Role.MEMBER:
        return MucRole.MEMBER;
      case Role.ADMIN:
        return MucRole.ADMIN;
      case Role.OWNER:
        return MucRole.OWNER;
      case Role.NONE:
        return MucRole.NONE;
    }
    throw Exception("Not Valid Role! $role");
  }

  Future<List<UidIdName?>> getFilteredMember(
    String roomUid, {
    String? query,
  }) async =>
      Stream.fromIterable(await getAllMembers(roomUid))
          .asyncMap((member) async {
            if (_authRepo.isCurrentUser(member!.memberUid)) {
              final a = await _accountRepo.getAccount();
              return UidIdName(
                uid: member.memberUid,
                id: a.userName,
                name: a.firstName,
              );
            } else {
              final uidIdName = await _uidIdNameDao.getByUid(member.memberUid);
              if (uidIdName!.uid.isBot()) {
                uidIdName.id = uidIdName.uid.asUid().node;
              }
              return uidIdName;
            }
          })
          .where((e) => e.id != null && e.id!.isNotEmpty)
          // TODO better pattern matching maybe be helpful
          .where(
            (e) =>
                query!.isEmpty ||
                (e.id != null &&
                    e.id!.toLowerCase().contains(query.toLowerCase())) ||
                (e.name != null &&
                    e.name!.toLowerCase().contains(query.toLowerCase())),
          )
          .toList();

  Future<void> _checkShowPin(
    Uid mucUid,
    List<Int64> pinMessages,
    List<int> pm,
  ) async {
    if (pinMessages.isEmpty) return;
    final showPin = pinMessages.last.toInt() > pm.last;
    if (showPin) {
      _mucDao.update(
        Muc(uid: mucUid.asString())
            .copyWith(uid: mucUid.asString(), showPinMessage: true),
      );
    }
  }
}
