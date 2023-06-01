// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver_public_protocol/pub/v1/broadcast.pb.dart';
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
import 'package:grpc/grpc.dart';
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
    List<Uid> memberUidList,
    String groupName,
    String info,
  ) async {
    final groupUid = await _mucServices.createNewGroup(groupName, info);
    if (groupUid != null) {
      await _sendAndSaveMucMembers(
        groupUid,
        memberUidList,
        groupName,
        info,
      );
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
      await _sendAndSaveMucMembers(
        channelUid,
        memberUidList,
        channelName,
        info,
        channelType: channelType,
        channelId: channelId,
      );
      return channelUid;
    }
    return null;
  }

  Future<Uid?> createNewBroadcast(
    List<Uid> memberUidList,
    String channelName,
    String info,
  ) async {
    final broadcastUid = await _mucServices.createNewBroadcast(
      channelName,
      info,
    );

    if (broadcastUid != null) {
      await _sendAndSaveMucMembers(
        broadcastUid,
        memberUidList,
        channelName,
        info,
      );
      return broadcastUid;
    }
    return null;
  }

  Future<void> _sendAndSaveMucMembers(
    Uid mucUid,
    List<Uid> memberUidList,
    String mucName,
    String mucInfo, {
    ChannelType? channelType,
    String? channelId,
  }) async {
    unawaited(addMucMember(mucUid, memberUidList));
    unawaited(
      _insertNewMucInfoToDb(
        mucUid,
        mucName,
        memberUidList.length + 1,
        mucInfo,
        channelId: channelId,
        mucType:
            channelType != null ? pbMucTypeToHiveMucType(channelType) : null,
      ),
    );
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

  Future<void> _fetchMucMembers(Uid mucUid, int len) async {
    try {
      var i = 0;
      var membersSize = 0;

      var finish = false;
      final members = <Member>[];
      while (i <= len || !finish) {
        var fetchedMemberPage = <muc_pb.Member>[];
        switch (mucUid.asMucCategories()) {
          case MucCategories.BROADCAST:
            final result =
                await _mucServices.getBroadcastMembers(mucUid, 15, i);
            finish = result.$2;
            fetchedMemberPage = result.$1;
          case MucCategories.CHANNEL:
            final result = await _mucServices.getChannelMembers(mucUid, 15, i);
            finish = result.$2;
            fetchedMemberPage = result.$1;
          case MucCategories.GROUP:
            final result = await _mucServices.getGroupMembers(mucUid, 15, i);
            finish = result.$2;
            fetchedMemberPage = result.$1;
          case MucCategories.NONE:
            break;
        }

        membersSize = membersSize + fetchedMemberPage.length;
        for (final member in fetchedMemberPage) {
          try {
            members.add(
              Member(
                mucUid: mucUid.asString(),
                memberUid: member.uid.asString(),
                role: getLocalRole(member.role),
              ),
            );
          } catch (e) {
            _logger.e(e);
          }
        }

        i = i + 15;
      }
      unawaited(updateMemberListOfMUC(mucUid, members));
      if (len <= membersSize) {
        return _mucDao.updateMuc(
          uid: mucUid.asString(),
          population: membersSize,
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<String> getGroupJointToken({required Uid groupUid}) async =>
      _mucServices.getGroupJointToken(groupUid: groupUid);

  Future<void> deleteGroupJointToken({required Uid groupUid}) async =>
      _mucServices.deleteGroupJointToken(groupUid: groupUid);

  Future<String> getChannelJointToken({required Uid channelUid}) async =>
      _mucServices.getChannelJointToken(channelUid: channelUid);

  Future<void> deleteChannelJointToken({required Uid channelUid}) async =>
      _mucServices.deleteChannelJointToken(channelUid: channelUid);

  // TODO(any): is it necessary to fetch all member every time???
  Future<Muc?> fetchMucInfo(Uid mucUid, {bool createNewRoom = false}) async {
    switch (mucUid.asMucCategories()) {
      case MucCategories.CHANNEL:
        final channel = await getChannelInfo(mucUid);
        final c = await _mucDao.get(mucUid.asString());
        if (channel != null) {
          final cType = pbMucTypeToHiveMucType(channel.info.type);
          if (createNewRoom) {
            await _roomDao.updateRoom(
              uid: mucUid,
              lastMessageId: channel.lastMessageId.toInt(),
              deleted: false,
            );
            GetIt.I
                .get<DataStreamServices>()
                .fetchLastNotHiddenMessage(
                  mucUid,
                  channel.lastMessageId.toInt(),
                  0,
                )
                .ignore();
          } else if (cType == MucType.Public) {
            final room = await _roomDao.getRoom(mucUid);
            if (room == null || createNewRoom) {
              await _roomDao.updateRoom(
                uid: mucUid,
                lastMessageId: channel.lastMessageId.toInt(),
                deleted: true,
              );
            }
            GetIt.I
                .get<DataStreamServices>()
                .fetchLastNotHiddenMessage(
                  mucUid,
                  channel.lastMessageId.toInt(),
                  0,
                )
                .ignore();
          } else if (cType == MucType.Private) {
            // TODO(any): do somethings relevant like remove channel if doesn't joined
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
              mucType: cType,
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

          if (channel.requesterRole != muc_pb.Role.NONE &&
              channel.requesterRole != muc_pb.Role.MEMBER) {
            unawaited(_fetchMucMembers(mucUid, channel.population.toInt()));
          }

          return _mucDao.get(mucUid.asString());
        }

      case MucCategories.BROADCAST:
        final broadcast = await _mucServices.getBroadcast(mucUid);
        if (broadcast != null) {
          if (createNewRoom) {
            await _roomDao.updateRoom(
              uid: mucUid,
              deleted: false,
            );
          }
          unawaited(
            _mucDao.updateMuc(
              uid: mucUid.asString(),
              name: broadcast.info.name,
              population: broadcast.population.toInt(),
              info: broadcast.info.info,
            ),
          );
          unawaited(_fetchMucMembers(mucUid, broadcast.population.toInt()));
        }
        return _mucDao.get(mucUid.asString());
      case MucCategories.GROUP:
        final group = await _mucServices.getGroup(mucUid);
        final m = await _mucDao.get(mucUid.asString());

        if (group != null) {
          if (createNewRoom) {
            await _roomDao.updateRoom(
              uid: mucUid,
              deleted: false,
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
              pinMessagesIdList:
                  group.pinMessages.map((e) => e.toInt()).toList(),
            ),
          );

          unawaited(_fetchMucMembers(mucUid, group.population.toInt()));
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

      case MucCategories.NONE:
        break;
    }
    return null;
  }

  Future<bool> isMucAdminOrOwner(String memberUid, String mucUid) async {
    final member = await _mucDao.getMember(mucUid, memberUid);
    return checkMucRoleIsMemberAdminOrOwner(member, mucUid);
  }


  Future<bool> checkMucRoleIsMemberAdminOrOwner(
    Member? member,
    String mucUid,
  ) async {
    if (member == null) {
      return false;
    }
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
    final member = await _mucDao.getMember(mucUid, userUid);
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

  Future<bool> removeGroup(Uid groupUid) async {
    final result = await _mucServices.removeGroup(groupUid);
    if (result) {
      await _deleteMucInformation(groupUid);
      return true;
    }
    return false;
  }

  Future<void> _deleteMucInformation(Uid mucUid) async {
    await _mucDao.delete(mucUid.asString());
    await _roomDao.updateRoom(uid: mucUid, deleted: true);
    await _mucDao.deleteAllMembers(mucUid.asString());
  }

  Future<bool> removeBroadcast(Uid broadcastUid) async {
    final result = await _mucServices.removeBroadcast(broadcastUid);
    if (result) {
      await _deleteMucInformation(broadcastUid);
      return true;
    }
    return false;
  }

  Future<bool> removeChannel(Uid channelUid) async {
    final result = await _mucServices.removeChannel(channelUid);
    if (result) {
      await _deleteMucInformation(channelUid);
      return true;
    }
    return false;
  }

  Future<GetChannelRes?> getChannelInfo(Uid channelUid) async =>
      _mucServices.getChannel(channelUid);

  Future<void> changeGroupMemberRole(Member groupMember) {
    final member = _covertDaoMucMemberToPbMucMember(groupMember);
    return _mucServices
        .changeGroupRole(member, groupMember.mucUid.asUid())
        .then((result) {
      if (result) {
        _mucDao.saveMember(groupMember);
      }
    });
  }

  Future<void> changeChannelMemberRole(Member channelMember) async {
    final member = _covertDaoMucMemberToPbMucMember(channelMember);
    final result = await _mucServices.changeCahnnelRole(
      member,
      channelMember.mucUid.asUid(),
    );
    if (result) {
      unawaited(_mucDao.saveMember(channelMember));
    }
  }

  Future<void> saveSmsBroadcastContact(Contact member, String uid) =>
      _mucDao.saveSmsBroadcastContact(member, uid);

  Future<void> deleteSmsBroadcastContact(Contact member, String uid) =>
      _mucDao.deleteSmsBroadcastContact(member, uid);

  Future<bool> leaveGroup(Uid groupUid) async {
    final result = await _mucServices.leaveGroup(groupUid);
    if (result) {
      await _deleteMucInformation(groupUid);
      return true;
    }
    return false;
  }

  Future<bool> leaveChannel(Uid channelUid) async {
    final result = await _mucServices.leaveChannel(channelUid);
    if (result) {
      await _deleteMucInformation(channelUid);
      return true;
    }
    return false;
  }

  Future<bool> kickGroupMember(Member groupMember) async {
    final member = _covertDaoMucMemberToPbMucMember(groupMember);
    final result = await _mucServices.kickGroupMembers(
      [member],
      groupMember.mucUid.asUid(),
    );
    if (result) {
      unawaited(_mucDao.deleteMember(groupMember));
      return true;
    }

    return false;
  }

  Future<bool> kickBroadcastMember(Member broadcastMember) async {
    final member = _covertDaoMucMemberToPbMucMember(broadcastMember);
    final result = await _mucServices.kickBroadcastMembers(
      [member],
      broadcastMember.mucUid.asUid(),
    );
    if (result) {
      unawaited(_mucDao.deleteMember(broadcastMember));
      return true;
    }

    return false;
  }

  Future<bool> kickChannelMember(Member channelMember) async {
    final member = _covertDaoMucMemberToPbMucMember(channelMember);
    final result = await _mucServices.kickChannelMembers(
      [member],
      channelMember.mucUid.asUid(),
    );
    if (result) {
      unawaited(_mucDao.deleteMember(channelMember));
      return true;
    }

    return false;
  }

  Future<void> banGroupMember(Member groupMember) async {
    final member = _covertDaoMucMemberToPbMucMember(groupMember);
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

  muc_pb.Member _covertDaoMucMemberToPbMucMember(Member groupMember) {
    final member = muc_pb.Member()
      ..uid = groupMember.memberUid.asUid()
      ..role = getRole(groupMember.role);
    return member;
  }

  Future<void> banChannelMember(Member channelMember) async {
    final member = _covertDaoMucMemberToPbMucMember(channelMember);
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
    final member = _covertDaoMucMemberToPbMucMember(groupMember);
    await _mucServices.banGroupMember(member, groupMember.mucUid.asUid());
    // TODO(any): change database
  }

  Future<void> unBanChannelMember(Member channelMember) async {
    final member = _covertDaoMucMemberToPbMucMember(channelMember);
    await _mucServices.unbanChannelMember(member, channelMember.mucUid.asUid());
    // TODO(any): change database
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

  Future<void> modifyGroup(Uid mucId, String name, String info) async {
    final isSet = await _mucServices.modifyGroup(
      group_pb.GroupInfo()
        ..name = name
        ..info = info,
      mucId,
    );
    if (isSet) {
      return _mucDao.updateMuc(uid: mucId.asString(), info: info, name: name);
    }
  }

  Future<void> modifyChannel(
    Uid mucUid,
    String name,
    String id,
    String info,
    ChannelType channelType,
  ) async {
    ChannelInfo channelInfo;
    channelInfo = id.isEmpty
        ? (ChannelInfo()
          ..name = name
          ..type = channelType
          ..info = info)
        : ChannelInfo()
      ..name = name
      ..id = id
      ..type = channelType
      ..info = info;

    if (await _mucServices.modifyChannel(channelInfo, mucUid)) {
      return _mucDao.updateMuc(
        uid: mucUid.asString(),
        id: id,
        info: info,
        name: name,
        mucType: pbMucTypeToHiveMucType(channelType),
      );
    }
  }

  Future<void> modifyBroadcast(Uid mucId, String name, String info) async {
    final isSet = await _mucServices.modifyBroadcast(
      BroadcastInfo()
        ..name = name
        ..info = info,
      mucId,
    );
    if (isSet) {
      return _mucDao.updateMuc(uid: mucId.asString(), info: info, name: name);
    }
  }

  Future<void> _insertNewMucInfoToDb(
    Uid mucUid,
    String mucName,
    int population,
    String info, {
    String? channelId,
    MucType? mucType,
  }) async {
    await _mucDao.updateMuc(
      uid: mucUid.asString(),
      name: mucName,
      info: info,
      population: population,
      id: channelId,
      mucType: mucType,
    );
    await _roomDao.updateRoom(
      uid: mucUid,
      lastMessageId: 1,
      lastUpdateTime: clock.now().millisecondsSinceEpoch,
    );
  }

  Future<int> addMucMember(Uid mucUid, List<Uid> memberUids) async {
    try {
      var usersAddCode = 0;
      final members = <muc_pb.Member>[];
      for (final uid in memberUids) {
        members.add(
          muc_pb.Member()
            ..uid = uid
            ..role = mucUid.isChannel() ? muc_pb.Role.NONE : muc_pb.Role.MEMBER,
        );
      }

      usersAddCode = await _addMucMember(
        mucUid,
        members,
      );

      // TODO(any): we don't need fetch all members when we create new muc??
      if (usersAddCode == StatusCode.ok) {
        unawaited(_fetchMucMembers(mucUid, members.length));
      }
      return usersAddCode;
    } catch (e) {
      _logger.e(e);
      return StatusCode.unknown;
    }
  }

  Future<int> _addMucMember(Uid mucUid, List<muc_pb.Member> members) {
    switch (mucUid.asMucCategories()) {
      case MucCategories.BROADCAST:
        return _mucServices.addBroadcastMembers(members, mucUid);
      case MucCategories.CHANNEL:
        return _mucServices.addChannelMembers(members, mucUid);
      case MucCategories.GROUP:
        return _mucServices.addGroupMembers(members, mucUid);
      case MucCategories.NONE:
        break;
    }
    return Future.value(0);
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
              if (_authRepo.isCurrentUser(member!.memberUid.asUid())) {
                final a = (await _accountRepo.getAccount())!;
                return UidIdName(
                  uid: member.memberUid,
                  id: a.username,
                  name: buildName(a.firstname, a.lastname),
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
        threshold: 0.2,
      ),
    )
        .search(query)
        .where((element) => element.score < 0.2)
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
    if (newPinedMessages.isEmpty || lastCancelMessageId == 0) {
      return;
    }
    if (lastCancelMessageId != newPinedMessages.last.toInt() ||
        newPinedMessages.last.toInt() > pinMessages.last) {
      _mucDao.updateMuc(
        uid: mucUid.asString(),
        lastCanceledPinMessageId: 0,
      );
    }
  }

  MucType pbMucTypeToHiveMucType(ChannelType channelType) {
    switch (channelType) {
      case ChannelType.PRIVATE:
        return MucType.Private;
      case ChannelType.PUBLIC:
        return MucType.Public;
    }
    return MucType.Public;
  }

  ChannelType hiveMucTypeToPbMucType(MucType mucType) {
    switch (mucType) {
      case MucType.Private:
        return ChannelType.PRIVATE;
      case MucType.Public:
        return ChannelType.PUBLIC;
    }
  }

  Stream<Member?> watchMember(String mucUid, String memberUid)=>_mucDao.watchMember(mucUid, memberUid);
}
