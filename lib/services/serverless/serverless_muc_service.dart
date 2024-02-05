import 'dart:async';

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart' as model;
import 'package:deliver/box/role.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_message_service.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/create_muc.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/muc.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/server_less_packet.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ServerLessMucService {
  final _serverLessService = GetIt.I.get<ServerLessService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _dataStreamService = GetIt.I.get<DataStreamServices>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  Future<Uid?> createGroup({
    required String name,
    required List<Uid> members,
  }) async {
    try {
      members.add(_authRepo.currentUserUid);
      final node =
          "$LOCAL_MUC_ID${DateTime.now().millisecondsSinceEpoch}${_authRepo.currentUserUid.node}";
      final groupUid = Uid(node: node, category: Categories.GROUP);
      if (true || settings.isSuperNode.value) {
        for (final member in members) {
          final ip = await _serverLessService.getIp(member.asString());
          if (ip != null) {
            await _serverLessService.sendRequest(
              ServerLessPacket(
                createLocalMuc: CreateLocalMuc(
                  creator: _authRepo.currentUserUid,
                  uid: groupUid,
                  name: name,
                  members: mapMembers(members),
                ),
              ),
              ip,
            );
          }
        }
      } else {
        unawaited(
          _serverLessService.sendRequest(
            ServerLessPacket(
              createLocalMuc: CreateLocalMuc(
                creator: _authRepo.currentUserUid,
                uid: groupUid,
                name: name,
                members: mapMembers(members),
              ),
              proxyMessage: true,
            ),
            _serverLessService.getSuperNodeIp()!,
          ),
        );
      }

      return groupUid;
    } catch (_) {
      _logger.e(_);
    }
    return null;
  }

  Future<Uid?> createChannel({
    required String name,
    required List<Uid> members,
  }) async {
    try {
      members.add(_authRepo.currentUserUid);
      final node =
          "$LOCAL_MUC_ID${DateTime.now().millisecondsSinceEpoch}${_authRepo.currentUserUid.node}";
      final channelUid = Uid(node: node, category: Categories.CHANNEL);
      if (settings.isSuperNode.value) {
        for (final member in members) {
          final ip = await _serverLessService.getIp(member.asString());
          if (ip != null) {
            await _serverLessService.sendRequest(
              ServerLessPacket(
                createLocalMuc: CreateLocalMuc(
                  creator: _authRepo.currentUserUid,
                  uid: channelUid,
                  name: name,
                  members: mapMembers(members),
                ),
              ),
              ip,
            );
          }
        }
      } else {
        unawaited(
          _serverLessService.sendRequest(
            ServerLessPacket(
              createLocalMuc: CreateLocalMuc(
                creator: _authRepo.currentUserUid,
                uid: channelUid,
                name: name,
                members: mapMembers(members),
              ),
              proxyMessage: true,
            ),
            _serverLessService.getSuperNodeIp()!,
          ),
        );
      }

      return channelUid;
    } catch (_) {
      _logger.e(_);
    }
    return null;
  }

  Iterable<Member> mapMembers(List<Uid> members) {
    return members.map(
      (e) => Member(
        uid: e,
        role: e.asString().isSameEntity(_authRepo.currentUserUid)
            ? Role.OWNER
            : Role.MEMBER,
      ),
    );
  }

  Future<void> addMember(Uid mucUid, List<Member> members) async {
    final olbMembers = await _mucDao.getAllMembers(mucUid);
    members.addAll(
      olbMembers.map((e) => Member(uid: e.memberUid, role: getRole(e.role))),
    );
    final addMembersReq = AddMembersReq(members: members)..channel = mucUid;
    for (final member in members) {
      final ip = await _serverLessService.getIp(member.uid.asString());
      if (ip != null) {
        await _serverLessService.sendRequest(
          ServerLessPacket(
            addMembersReq: addMembersReq,
            name: (await _mucDao.get(mucUid))?.name ?? "",
            uid: _authRepo.currentUserUid,
          ),
          ip,
        );
      }
    }
  }

  Future<void> kickMember() async {}

  Future<void> handleAddMember(
    AddMembersReq addMembersReq, {
    required String name,
    required String from,
  }) async {
    await _uidIdNameDao.update(addMembersReq.channel, name: name);
    await _mucDao.updateMuc(
      uid: addMembersReq.channel,
      name: name,
      currentUserRole: getLocalRole(
        addMembersReq.members
            .where(
              (element) =>
                  element.uid.isSameEntity(_authRepo.currentUserUid.asString()),
            )
            .first
            .role,
      ),
      population: addMembersReq.members.length,
    );

    final oldMembers = await _mucDao.getAllMembers(addMembersReq.channel);
    for (final element in addMembersReq.members) {
      await _mucDao.saveMember(
        model.Member(
          memberUid: element.uid,
          mucUid: addMembersReq.channel,
          role: getLocalRole(element.role),
        ),
      );
    }

    final muc = await _roomDao.getRoom(addMembersReq.channel);

    for (final element in addMembersReq.members) {
      if (!oldMembers.contains(
        model.Member(
          memberUid: element.uid,
          mucUid: addMembersReq.channel,
          role: getLocalRole(element.role),
        ),
      )) {
        await _dataStreamService.handleIncomingMessage(
          Message()
            ..id = Int64(muc != null ? muc.lastMessageId + 1 : 1)
            ..from = addMembersReq.channel
            ..to = _authRepo.currentUserUid
            ..time = Int64(
              DateTime.now().millisecondsSinceEpoch,
            )
            ..persistEvent = PersistentEvent(
              mucSpecificPersistentEvent: MucSpecificPersistentEvent(
                issue: MucSpecificPersistentEvent_Issue.ADD_USER,
                issuer: Uid(node: from),
                assignee: element.uid,
              ),
            ),
          isOnlineMessage: true,
        );
      }
    }
  }

  Future<void> handleCreateMuc(
      CreateLocalMuc createLocalMuc, bool proxyMessage) async {
    try {
      if (proxyMessage) {
        //todo
      } else {
        await _uidIdNameDao.update(createLocalMuc.uid,
            name: createLocalMuc.name);
        await _mucDao.updateMuc(
          uid: createLocalMuc.uid,
          name: createLocalMuc.name,
          currentUserRole: getLocalRole(
            createLocalMuc.members
                .where(
                  (element) => element.uid
                      .isSameEntity(_authRepo.currentUserUid.asString()),
                )
                .first
                .role,
          ),
          population: createLocalMuc.members.length,
        );
        for (final element in createLocalMuc.members) {
          await _mucDao.saveMember(
            model.Member(
              memberUid: element.uid,
              mucUid: createLocalMuc.uid,
              role: getLocalRole(element.role),
            ),
          );
        }

        await _dataStreamService.handleIncomingMessage(
          Message()
            ..id = Int64(1)
            ..from = createLocalMuc.uid
            ..to = _authRepo.currentUserUid
            ..time = Int64(
              DateTime.now().millisecondsSinceEpoch,
            )
            ..persistEvent = PersistentEvent(
              mucSpecificPersistentEvent: MucSpecificPersistentEvent(
                issue: MucSpecificPersistentEvent_Issue.MUC_CREATED,
                issuer: createLocalMuc.creator,
                assignee: createLocalMuc.uid,
                name: createLocalMuc.name,
              ),
            ),
          isOnlineMessage: true,
        );
      }
    } catch (_) {
      _logger.e(_);
    }
  }

  Role getRole(MucRole role) {
    switch (role) {
      case MucRole.MEMBER:
        return Role.MEMBER;
      case MucRole.ADMIN:
        return Role.ADMIN;
      case MucRole.OWNER:
        return Role.OWNER;
      case MucRole.NONE:
        return Role.NONE;
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

  Future<void> sendMessage(Message message) async {
    try {
      if (settings.isSuperNode.value) {
        unawaited(sendMessageToMucUsers(message));
      } else {
        final uid = _serverLessService.getSuperNode();
        if (uid != null) {
          if (message.hasFile()) {
            final fileInfo = await _sendFileToMucMember(message, uid);
            if (fileInfo != null) {
              message.file = fileInfo;
            }
          }
          unawaited(
            _serverLessService.sendRequest(
              ServerLessPacket(
                proxyMessage: true,
                message: message,
              ),
              _serverLessService.address[uid.asString()]!,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendMessageToMucUsers(Message message) async {
    try {
      for (final member in await _mucDao.getAllMembers(message.to)) {
        if (!member.memberUid.isSameEntity(message.from.asString())) {
          if (member.memberUid
              .isSameEntity(_authRepo.currentUserUid.asString())) {
            unawaited(
              GetIt.I.get<ServerLessMessageService>().processMessage(message),
            );
          } else {
            if (message.hasFile()) {
              final fileInfo =
                  await _sendFileToMucMember(message, member.memberUid);
              if (fileInfo != null) {
                _sendMessageToMember(member, message..file = fileInfo);
              }
            }
            if (message.hasText()) {
              _sendMessageToMember(member, message);
            }
          }
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<File?> _sendFileToMucMember(Message message, Uid uid) async {
    final info = message.file;
    final fileInfo = await _fileRepo.uploadClonedFile(
      info.uuid,
      info.name,
      uid: uid,
      isVoice: info.isVoice,
      packetIds: [message.packetId],
    );
    return fileInfo;
  }

  void _sendMessageToMember(model.Member member, Message message) {
    final ip = _serverLessService.address[member.memberUid.asString()];
    if (ip != null) {
      unawaited(
        _serverLessService.sendRequest(
          ServerLessPacket(message: message),
          ip,
        ),
      );
    }
  }
}
