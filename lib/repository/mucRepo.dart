// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/data_stream_services.dart';
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
import 'package:fuzzy/fuzzy.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class MucRepo {
  final _logger = GetIt.I.get<Logger>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
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
      unawaited(sendMembers(groupUid, memberUids));
      unawaited(_insertToDb(groupUid, groupName, memberUids.length + 1, info));
      return groupUid;
    }
    return null;
  }

  Future<Uid?> createNewChannel(
    String channelId,
    List<Uid> memberUidList,
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
      await sendMembers(channelUid, memberUidList);
      unawaited(
        _mucDao.saveMember(
          Member(
            memberUid: _authRepo.currentUserUid.asString(),
            mucUid: channelUid.asString(),
            role: MucRole.OWNER,
          ),
        ),
      );
      unawaited(
        _insertToDb(
          channelUid,
          channelName,
          memberUidList.length + 1,
          info,
          channelId: channelId,
        ),
      );
      unawaited(fetchMucInfo(channelUid));
      unawaited(fetchChannelMembers(channelUid, memberUidList.length));
      return channelUid;
    }
    return null;
  }

  Future<bool> channelIdIsAvailable(String id) async {
    try {
      final result = await _sdr.queryServiceClient
          .idIsAvailable(IdIsAvailableReq()..id = id);
      return result.isAvailable;
    } catch (e) {
      return false;
    }
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
      unawaited(updateMemberListOfMUC(groupUid, members));
      if (len <= membersSize) {
        return _mucDao.updateMuc(
          uid: groupUid.asString(),
          population: membersSize,
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<String> getGroupJointToken({required Uid groupUid}) async =>
      _mucServices.getGroupJointToken(groupUid: groupUid);

  Future<String> getChannelJointToken({required Uid channelUid}) async =>
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
            await _mucDao.updateMuc(
              uid: channelUid.asString(),
              population: membersSize,
            );
          }
        }
      }
      return updateMemberListOfMUC(channelUid, members);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<Muc?> fetchMucInfo(Uid mucUid, {bool createNewRoom = false}) async {
    if (mucUid.category == Categories.GROUP) {
      final group = await _mucServices.getGroup(mucUid);
      final m = await _mucDao.get(mucUid.asString());

      if (group != null) {
        if (createNewRoom) {
          await _roomDao.updateRoom(
            uid: mucUid.asString(),
            lastMessageId: group.lastMessageId.toInt(),
          );
        }

        unawaited(
          _mucDao.updateMuc(
            uid: mucUid.asString(),
            name: group.info.name,
            population: group.population.toInt(),
            info: group.info.info,
            token: group.token,
            pinMessagesIdList: group.pinMessages.map((e) => e.toInt()).toList(),
          ),
        );

        unawaited(fetchGroupMembers(mucUid, group.population.toInt()));
        if (m != null) {
          _checkShowPin(
            mucUid,
            m.lastCanceledPinMessageId,
            group.pinMessages,
            m.pinMessagesIdList,
          );
        }

        return _mucDao.get(mucUid.asString());
      }
      return null;
    } else {
      final channel = await getChannelInfo(mucUid);
      final c = await _mucDao.get(mucUid.asString());
      if (channel != null) {
        if (createNewRoom) {
          await _roomDao.updateRoom(
            uid: mucUid.asString(),
            lastMessageId: channel.lastMessageId.toInt(),
          );
          GetIt.I
              .get<DataStreamServices>()
              .fetchLastNotHiddenMessage(
                mucUid,
                channel.lastMessageId.toInt(),
                0,
              )
              .ignore();
        }

        unawaited(
          _mucDao.updateMuc(
            uid: mucUid.asString(),
            name: channel.info.name,
            population: channel.population.toInt(),
            info: channel.info.info,
            token: channel.token,
            lastCanceledPinMessageId:
                c != null ? c.lastCanceledPinMessageId : 0,
            pinMessagesIdList:
                channel.pinMessages.map((e) => e.toInt()).toList(),
            id: channel.info.id,
          ),
        );

        if (c != null) {
          _checkShowPin(
            mucUid,
            c.lastCanceledPinMessageId,
            channel.pinMessages,
            c.pinMessagesIdList,
          );
        }
        // ignore: unrelated_type_equality_checks
        if (channel.requesterRole != muc_pb.Role.NONE &&
            channel.requesterRole != muc_pb.Role.MEMBER) {
          unawaited(fetchChannelMembers(mucUid, channel.population.toInt()));
        }

        return _mucDao.get(mucUid.asString());
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
      await _mucDao.delete(groupUid.asString());
      await _roomDao.updateRoom(uid: groupUid.asString(), deleted: true);
      await _mucDao.deleteAllMembers(groupUid.asString());
      return true;
    }
    return false;
  }

  Future<bool> _removeChannel(Uid channelUid) async {
    final result = await _mucServices.removeChannel(channelUid);
    if (result) {
      await _mucDao.delete(channelUid.asString());
      await _roomDao.updateRoom(uid: channelUid.asString(), deleted: true);
      await _mucDao.deleteAllMembers(channelUid.asString());
      return true;
    }
    return false;
  }

  Future<GetChannelRes?> getChannelInfo(Uid channelUid) async =>
      _mucServices.getChannel(channelUid);

  Future<void> changeGroupMemberRole(Member groupMember) {
    final member = muc_pb.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    return _mucServices
        .changeGroupRole(member, groupMember.mucUid.asUid())
        .then((result) {
      if (result) {
        _mucDao.saveMember(groupMember);
      }
    });
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
      unawaited(_mucDao.saveMember(channelMember));
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
      await _mucDao.delete(groupUid.asString());
      await _roomDao.updateRoom(uid: groupUid.asString(), deleted: true);
      return true;
    }
    return false;
  }

  Future<bool> _leaveChannel(Uid channelUid) async {
    final result = await _mucServices.leaveChannel(channelUid);
    if (result) {
      await _mucDao.delete(channelUid.asString());
      await _roomDao.updateRoom(uid: channelUid.asString(), deleted: true);
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
        unawaited(_mucDao.deleteMember(member));
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
        unawaited(_mucDao.deleteMember(member));
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
        return _mucDao.deleteMember(groupMember);
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
        unawaited(_mucDao.deleteMember(channelMember));
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
      return fetchMucInfo(groupUid, createNewRoom: true);
    }
    return null;
  }

  Future<Muc?> joinChannel(Uid channelUid, String token) async {
    final result = await _mucServices.joinChannel(channelUid, token);
    if (result) {
      return fetchMucInfo(channelUid, createNewRoom: true);
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
      return _mucDao.updateMuc(uid: mucId, info: info, name: name);
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
      return _mucDao.updateMuc(uid: mucUid, id: id, info: info, name: name);
    }
  }

  Future<void> _insertToDb(
    Uid mucUid,
    String mucName,
    int population,
    String info, {
    String? channelId,
  }) async {
    await _mucDao.updateMuc(
      uid: mucUid.asString(),
      name: mucName,
      info: info,
      population: population,
      id: channelId,
    );
    await _roomDao.updateRoom(uid: mucUid.asString());
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
          unawaited(fetchGroupMembers(mucUid, members.length));
        } else {
          unawaited(fetchChannelMembers(mucUid, members.length));
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<void> updateMemberListOfMUC(Uid mucUid, List<Member> members) async {
    if (members.isNotEmpty) {
      await _mucDao.deleteAllMembers(mucUid.asString());
    }
    for (final member in members) {
      unawaited(_mucDao.saveMember(member));
      unawaited(_contactRepo.fetchMemberId(member));
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
  }) async {
    final uidIdNameList =
        await Stream.fromIterable(await getAllMembers(roomUid))
            .asyncMap((member) async {
              if (_authRepo.isCurrentUser(member!.memberUid)) {
                final a = (await _accountRepo.getAccount())!;
                return UidIdName(
                  uid: member.memberUid,
                  id: a.username,
                  name: a.firstname,
                );
              } else {
                final uidIdName =
                    await _uidIdNameDao.getByUid(member.memberUid);
                if (uidIdName!.uid.isBot()) {
                  uidIdName.id = uidIdName.uid.asUid().node;
                }
                return uidIdName;
              }
            })
            .where((e) => e.id != null && e.id!.isNotEmpty)
            .toList();
    final fuzzyName = _getFuzzyList(
      uidIdNameList
          .where((element) => element.name != null)
          .map((event) => event.name)
          .toList(),
      query!,
    );
    final fuzzyId =
        _getFuzzyList(uidIdNameList.map((event) => event.id).toList(), query);

    return uidIdNameList
        .where(
          (e) =>
              query.isEmpty ||
              (fuzzyId.isNotEmpty && fuzzyId.contains(e.id)) ||
              (e.name != null &&
                  fuzzyName.isNotEmpty &&
                  fuzzyName.contains(e.name)),
        )
        .toList();
  }

  List<dynamic> _getFuzzyList(List<String?> list, String query) {
    final fuzzy = Fuzzy(
      list,
      options: FuzzyOptions(
        tokenize: true,
        threshold: 0.3,
      ),
    )
        .search(query)
        .where((element) => element.score < 0.4)
        .map((e) => e.item)
        .toList();
    return fuzzy;
  }

  void _checkShowPin(
    Uid mucUid,
    int lastCancelMessageId,
    List<Int64> newPinedMessages,
    List<int> pinMessages,
  ) {
    if (newPinedMessages.isEmpty || lastCancelMessageId == 0) return;
    if (lastCancelMessageId != newPinedMessages.last.toInt() ||
        newPinedMessages.last.toInt() > pinMessages.last) {
      _mucDao.updateMuc(
        uid: mucUid.asString(),
        lastCanceledPinMessageId: 0,
      );
    }
  }
}
