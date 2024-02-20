import 'dart:async';

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/serverless_requests_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/member.dart' as model;
import 'package:deliver/box/role.dart';
import 'package:deliver/box/serverless_requests.dart';
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
  final _serverLessRequestDao = GetIt.I.get<ServerLessRequestsDao>();

  Future<bool> createGroup({
    required String name,
    required String groupNode,
    required List<Uid> members,
  }) async {
    try {
      members.add(_authRepo.currentUserUid);
      final createGroup = CreateLocalMuc(
        creator: _authRepo.currentUserUid,
        uid: Uid(category: Categories.GROUP, node: groupNode),
        name: name,
        members: mapMembers(members),
      );

      final serverLessPacket = ServerLessPacket(
        createLocalMuc: createGroup,
      );

      if (settings.isSuperNode.value) {
        for (final member in members) {
          unawaited(_sendClientPacket(member.asString(), serverLessPacket));
        }
      } else {
        final uid = _serverLessService.getSuperNode();
        if (uid != null) {
          unawaited(
            _sendClientPacket(
              uid.asString(),
              serverLessPacket..proxyMessage = true,
            ),
          );
        }
      }
      unawaited(_saveLocalMuc(createGroup));

      return true;
    } catch (_) {
      _logger.e(_);
      return false;
    }
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
          final ip = await _serverLessService.getIpAsync(member.asString());
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
    final addMemberToMuc = AddMemberToLocalMuc(
      name: (await _mucDao.get(mucUid))?.name ?? "",
      issuer: Member(uid: _authRepo.currentUserUid),
      mucUid: mucUid,
      oldMembers: olbMembers.map((e) => _convertMember(e)),
      newMembers: members,
    );
    final packet = ServerLessPacket(addMembers: addMemberToMuc);
    if (settings.isSuperNode.value) {
      unawaited(
        _propactaingAddMemberToGroup(
          addMemberToMuc,
        ),
      );
    } else {
      unawaited(
        _serverLessService.sendRequest(
          packet..proxyMessage = true,
          _serverLessService.getSuperNodeIp()!,
        ),
      );
      //
    }
  }

  Future<void> _propactaingAddMemberToGroup(
      AddMemberToLocalMuc addMemberToLocalMuc) async {
    final allMembers = [
      ...addMemberToLocalMuc.newMembers,
      ...addMemberToLocalMuc.oldMembers
    ];

    for (final member in allMembers) {
      try {
        if (member.uid.isSameEntity(_authRepo.currentUserUid.asString())) {
          unawaited(_addMember(addMemberToLocalMuc));
        } else {
          final ip = _serverLessService.getIp(member.uid.asString());
          if (ip != null) {
            unawaited(
              _serverLessService.sendRequest(
                ServerLessPacket(
                  addMembers: AddMemberToLocalMuc(
                    name:
                        (await _mucDao.get(addMemberToLocalMuc.mucUid))?.name ??
                            "",
                    issuer: Member(uid: _authRepo.currentUserUid),
                    mucUid: addMemberToLocalMuc.mucUid,
                    oldMembers: addMemberToLocalMuc.oldMembers,
                    newMembers: addMemberToLocalMuc.newMembers,
                  ),
                ),
                ip,
              ),
            );
          }
        }
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  Future<void> kickMember() async {}

  Future<void> handleAddMember(
      AddMemberToLocalMuc addMemberToLocalMuc, bool proxy) async {
    if (proxy) {
      _propactaingAddMemberToGroup(addMemberToLocalMuc);
    } else {
      unawaited(_addMember(addMemberToLocalMuc));
    }
  }

  Future<void> _addMember(AddMemberToLocalMuc addMemberToLocalMuc) async {
    final muc = await _mucDao.get(addMemberToLocalMuc.mucUid);
    await _uidIdNameDao.update(
      addMemberToLocalMuc.mucUid,
      name: addMemberToLocalMuc.name,
    );
    unawaited(
      _mucDao.updateMuc(
        uid: addMemberToLocalMuc.mucUid,
        name: addMemberToLocalMuc.name,
        // currentUserRole: getLocalRole(
        //   addMemberToLocalMuc.newMembers
        //       .where(
        //         (element) => element.uid
        //             .isSameEntity(_authRepo.currentUserUid.asString()),
        //       )
        //       .first
        //       .role,
        // ),
        population: addMemberToLocalMuc.oldMembers.length +
            addMemberToLocalMuc.newMembers.length,
      ),
    );
    if (muc == null) {
      for (final element in addMemberToLocalMuc.oldMembers
        ..addAll(addMemberToLocalMuc.newMembers)) {
        await _mucDao.saveMember(
          model.Member(
            memberUid: element.uid,
            mucUid: addMemberToLocalMuc.mucUid,
            role: getLocalRole(element.role),
          ),
        );
      }
      unawaited(
        _createGroupMessage(
          Member(uid: _authRepo.currentUserUid),
          addMemberToLocalMuc.name,
          addMemberToLocalMuc.issuer.uid,
          addMemberToLocalMuc.mucUid,
        ),
      );
    } else {
      for (final member in addMemberToLocalMuc.newMembers) {
        await _mucDao.saveMember(
          model.Member(
            memberUid: member.uid,
            mucUid: addMemberToLocalMuc.mucUid,
            role: getLocalRole(member.role),
          ),
        );
        unawaited(
          _createGroupMessage(
            member,
            addMemberToLocalMuc.name,
            addMemberToLocalMuc.issuer.uid,
            addMemberToLocalMuc.mucUid,
          ),
        );
      }
    }
  }

  Future<void> _createGroupMessage(
    Member member,
    String name,
    Uid issuer,
    Uid roomUId,
  ) async {
    await _dataStreamService.handleIncomingMessage(
      Message()
        ..id = Int64(GetIt.I
            .get<ServerLessMessageService>()
            .getRoomLastMessageId(roomUId))
        ..isLocalMessage = true
        ..from = roomUId
        ..packetId = DateTime.now().millisecondsSinceEpoch.toString()
        ..to = _authRepo.currentUserUid
        ..time = Int64(
          DateTime.now().millisecondsSinceEpoch,
        )
        ..persistEvent = PersistentEvent(
          mucSpecificPersistentEvent: MucSpecificPersistentEvent(
            issue: MucSpecificPersistentEvent_Issue.ADD_USER,
            issuer: issuer,
            assignee: member.uid,
          ),
        ),
      isOnlineMessage: true,
    );
  }

  Future<void> handleCreateMuc(
    CreateLocalMuc createLocalMuc, {
    bool proxyMessage = false,
  }) async {
    try {
      if (proxyMessage) {
        for (final member in createLocalMuc.members) {
          if (_authRepo.currentUserUid.isSameEntity(member.uid.asString())) {
            await _saveLocalMuc(createLocalMuc);
          } else {
            unawaited(
              _sendClientPacket(
                member.uid.asString(),
                ServerLessPacket(createLocalMuc: createLocalMuc),
              ),
            );
          }
        }
      } else {
        await _saveLocalMuc(createLocalMuc);
      }
    } catch (_) {
      _logger.e(_);
    }
  }

  Future<void> _saveLocalMuc(CreateLocalMuc createLocalMuc) async {
    await _uidIdNameDao.update(
      createLocalMuc.uid,
      name: createLocalMuc.name,
    );
    await _mucDao.updateMuc(
      uid: createLocalMuc.uid,
      name: createLocalMuc.name,
      currentUserRole: getLocalRole(
        createLocalMuc.members
            .where(
              (element) =>
                  element.uid.isSameEntity(_authRepo.currentUserUid.asString()),
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

    unawaited(
      _dataStreamService.handleIncomingMessage(
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
      ),
    );
  }

  Member _convertMember(model.Member m) =>
      Member(uid: m.memberUid, role: getRole(m.role));

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
        unawaited(
          sendMessageToMucUsers(
            message,
            (await (_mucDao.getAllMembers(message.to)))
                .map((e) => e.memberUid)
                .toList(),
          ),
        );
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
                members: (await (_mucDao.getAllMembers(message.to)))
                    .map((e) => e.memberUid)
                    .toList(),
                proxyMessage: true,
                message: message,
              ),
              _serverLessService.getIp(uid.asString())!,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendMessageToMucUsers(Message message, List<Uid> members) async {
    try {
      for (final member in members) {
        if (!member.isSameEntity(message.from.asString())) {
          if (member.isSameEntity(_authRepo.currentUserUid.asString())) {
            unawaited(
              GetIt.I.get<ServerLessMessageService>().processMessage(message),
            );
          } else {
            if (message.hasFile()) {
              final fileInfo = await _sendFileToMucMember(message, member);
              if (fileInfo != null) {
                unawaited(
                  _sendClientPacket(
                    member.asString(),
                    ServerLessPacket(message: message..file = fileInfo),
                  ),
                );
              }
            } else if (message.hasText()) {
              unawaited(
                _sendClientPacket(
                  member.asString(),
                  ServerLessPacket(message: message),
                ),
              );
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

  Future<bool> _sendClientPacket(
    String memberUid,
    ServerLessPacket packet, {
    bool needToSave = true,
  }) async {
    try {
      final ip = _serverLessService.getIp(memberUid);
      if (ip != null) {
        final res = await _serverLessService.sendRequest(
          packet,
          ip,
        );
        if (res == null || res.statusCode != 200) {
          if (needToSave) {
            unawaited(_saveUnSuccessClientPacket(memberUid, packet));
          }
          return false;
        }
      } else {
        if (needToSave) {
          unawaited(_saveUnSuccessClientPacket(memberUid, packet));
        }
        return false;
      }
      return true;
    } catch (e) {
      _logger.e(e);
      if (needToSave) {
        unawaited(_saveUnSuccessClientPacket(memberUid, packet));
      }
      return false;
    }
  }

  Future<void> _saveUnSuccessClientPacket(
    String memberUid,
    ServerLessPacket serverLessPacket,
  ) async {
    try {
      unawaited(
        _serverLessRequestDao.save(
          ServerLessRequest(
            uid: memberUid,
            info: serverLessPacket.writeToJson(),
            time: DateTime.now().microsecondsSinceEpoch,
          ),
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> resendPendingPackets(Uid uid) async {
    try {
      final packets = (await _serverLessRequestDao.getUserRequests(uid))
        ..sort((a, b) => a.time - b.time);
      for (final packet in packets) {
        final severLessPacket = ServerLessPacket.fromJson(packet.info);
        if (severLessPacket.hasMessage() && severLessPacket.message.hasFile()) {
          final fileInfo =
              await _sendFileToMucMember(severLessPacket.message, uid);
          if (fileInfo != null) {
            severLessPacket.message.file = fileInfo;
          }
        }
        if (await _sendClientPacket(uid.asString(), severLessPacket,
            needToSave: false)) {
          await _serverLessRequestDao.remove(packet);
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
