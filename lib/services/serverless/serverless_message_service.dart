import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_file_service.dart';
import 'package:deliver/services/serverless/serverless_muc_service.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/utils/message_utils.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/create_muc.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/local_network_file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ServerLessMessageService {
  final Map<String, List<Seen>> _pendingSeen = {};
  final Map<String, List<MessageDeliveryAck>> _pendingAck = {};
  final _roomDao = GetIt.I.get<RoomDao>();
  final _dataStreamService = GetIt.I.get<DataStreamServices>();
  final _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _serverLessFileService = GetIt.I.get<ServerLessFileService>();
  final _callService = GetIt.I.get<CallService>();
  final _serverLessService = GetIt.I.get<ServerLessService>();
  final _serverLessMucService = GetIt.I.get<ServerLessMucService>();
  final _logger = GetIt.I.get<Logger>();

  Future<void> sendClientPacket(ClientPacket clientPacket, {int? id}) async {
    switch (clientPacket.whichType()) {
      case ClientPacket_Type.message:
        final room = await _roomDao.getRoom(clientPacket.message.to);
        if (clientPacket.message.hasText()) {
          unawaited(
            _sendTextMessage(
              clientPacket.message,
              id ?? (room != null ? room.lastMessageId + 1 : 1),
              edited: id != null,
            ),
          );
        } else if (clientPacket.message.hasFile()) {
          unawaited(
            _sendFileMessage(
              clientPacket.message,
              room != null ? room.lastMessageId + 1 : 1,
            ),
          );
        }
        break;
      case ClientPacket_Type.seen:
        final uid = clientPacket.seen.to;
        if (await _serverLessService.getIp(uid.asString()) != null) {
          unawaited(
            _sendSeen(
              Seen()
                ..to = clientPacket.seen.to
                ..from = _authRepo.currentUserUid
                ..id = clientPacket.seen.id,
            ),
          );
        } else {
          if (_pendingSeen[uid.asString()] == null) {
            _pendingSeen[uid.asString()] = [];
          }
          _pendingSeen[uid.asString()]!.add(
            Seen()
              ..to = clientPacket.seen.to
              ..from = _authRepo.currentUserUid
              ..id = clientPacket.seen.id,
          );
        }
        break;
      case ClientPacket_Type.activity:
        unawaited(_sendActivity(clientPacket.activity));
        break;
      case ClientPacket_Type.ping:
      case ClientPacket_Type.callOffer:
      case ClientPacket_Type.callAnswer:
        break;
      case ClientPacket_Type.callEvent:
        final callEvent = clientPacket.callEvent;
        await _sendCallEvent(callEvent);
        break;
      case ClientPacket_Type.notSet:
        break;
    }
  }

  Future<void> _sendTextMessage(
    MessageByClient messageByClient,
    int id, {
    bool edited = false,
  }) async {
    final message = Message()
      ..from = _authRepo.currentUserUid
      ..to = messageByClient.to
      ..packetId = messageByClient.packetId
      ..replyToId = messageByClient.replyToId
      ..id = Int64(id)
      ..edited = edited
      ..text = messageByClient.text
      ..forwardFrom = messageByClient.forwardFrom
      ..time = Int64(
        DateTime.now().millisecondsSinceEpoch,
      );

    await _sendMessage(to: message.to, message: message);
  }

  Future<void> _sendActivity(ActivityByClient activity) async {
    final ip = await _serverLessService.getIp(activity.to.asString());
    if (ip != null) {
      unawaited(
        _serverLessService.sendRequest(
          Activity(
            from: _authRepo.currentUserUid,
            to: activity.to,
            typeOfActivity: activity.typeOfActivity,
          ).writeToBuffer(),
          ip,
          type: ACTIVITY,
        ),
      );
    }
  }

  Future<void> _sendFileMessage(
    MessageByClient messageByClient,
    int id,
  ) async {
    final message = Message()
      ..from = _authRepo.currentUserUid
      ..to = messageByClient.to
      ..packetId = messageByClient.packetId
      ..replyToId = messageByClient.replyToId
      ..id = Int64(id)
      ..file = messageByClient.file
      ..forwardFrom = messageByClient.forwardFrom
      ..time = Int64(
        DateTime.now().millisecondsSinceEpoch,
      );
    await _sendMessage(to: message.to, message: message);
  }

  void deleteMessage(DeleteMessageReq deleteMessageReq) {
    _sendMessage(
      to: deleteMessageReq.roomUid,
      message: Message()
        ..to = deleteMessageReq.roomUid
        ..from = _authRepo.currentUserUid
        ..persistEvent = PersistentEvent(
          messageManipulationPersistentEvent:
              MessageManipulationPersistentEvent(
            action: MessageManipulationPersistentEvent_Action.DELETED,
            messageId: deleteMessageReq.messageId,
          ),
        ),
    );
  }

  void editMessage({
    required MessageByClient messageByClient,
    required int messageId,
  }) {
    unawaited(
      sendClientPacket(
        ClientPacket()..message = messageByClient,
        id: messageId,
      ),
    );
  }

  Future<void> _sendMessage({required Uid to, required Message message}) async {
    if (to.category == Categories.USER) {
      final ip = await _serverLessService.getIp(to.asString());
      if (ip != null) {
        unawaited(
          _serverLessService.sendRequest(
            message.writeToBuffer(),
            ip,
          ),
        );
      }
    } else if (to.category == Categories.GROUP ||
        to.category == Categories.CHANNEL) {
      final members = await GetIt.I.get<MucDao>().getAllMembers(to);
      for (final element in members) {
        final ip = await _serverLessService.getIp(element.memberUid.asString());
        if (ip != null) {
          unawaited(
            _serverLessService.sendRequest(message.writeToBuffer(), ip),
          );
        }
      }
    }
    Timer(
      const Duration(seconds: 5),
      () => _checkPendingStatus(message.packetId),
    );
  }

  Future<void> _checkPendingStatus(String packetId) async {
    final pm = await _pendingMessageDao.getPendingMessage(packetId);
    if (pm != null) {
      await _pendingMessageDao.savePendingMessage(
        pm.copyWith(
          failed: true,
        ),
      );
      _serverLessService.sendBroadCast(to: pm.roomUid);
    }
  }

  Future<void> processRequest(HttpRequest request) async {
    try {
      final type = request.headers.value(TYPE) ?? MESSAGE;
      if (type == ACK ) {
        unawaited(
          _dataStreamService.handleAckMessage(
            MessageDeliveryAck.fromBuffer(await request.first),
            isLocalNetworkMessage: true,
          ),
        );
      } else if (type == SEEN) {
        unawaited(
          _dataStreamService.handleSeen(Seen.fromBuffer(await request.first)),
        );
      } else if (type == MESSAGE) {
        unawaited(
          _processMessage(request),
        );
      } else if (type == CREATE_MUC) {
        unawaited(
          _serverLessMucService.handleCreateMuc(
            CreateLocalMuc.fromBuffer(await request.first),
          ),
        );
      } else if (type == ADD_MEMBER_TO_MUC) {
        unawaited(
          _serverLessMucService.handleAddMember(
            AddMembersReq.fromBuffer(
              await request.first,
            ),
            from: request.headers.value(MUC_ADD_MEMBER_REQUESTER)!,
            name: request.headers.value(MUC_NAME)!,
          ),
        );
      } else if (type == ACTIVITY) {
        _dataStreamService
            .handleActivity(Activity.fromBuffer(await request.first));
      } else if (type == SEND_FILE_REQ) {
        unawaited(
          _serverLessFileService.startFileServer(),
        );
      } else if (type == RESEND_FILE_REQ) {
        final resendFileRequest =
            ResendFileRequest.fromBuffer(await request.first);
        unawaited(
          _serverLessFileService.resendFile(
            ip: request.headers.value(IP)!,
            uuid: resendFileRequest.uuid,
            name: resendFileRequest.name,
          ),
        );
      } else if (type == CALL_EVENT) {
        final callEvents = CallEvents.callEvent(
          CallEventV2.fromBuffer(await request.first),
        );
        _callService
          ..addCallEvent(callEvents)
          ..shouldRemoveData = false;
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _sendPendingMessage(String uid) async {
    final messages = await _pendingMessageDao.getPendingMessages(uid);
    var j = 0;
    while (j < messages.length) {
      try {
        await sendClientPacket(
          ClientPacket()
            ..message = MessageUtils.createMessageByClient(messages[j].msg),
        );
        await Future.value(const Duration(milliseconds: 600));
      } catch (e) {
        _logger.e(e);
      }

      j++;
    }
  }

  Future<bool> sendFileSendRequestMessage({
    required Uid to,
    required String uuid,
  }) async {
    try {
      final ip = await _serverLessService.getIp(to.asString());
      if (ip != null) {
        await _serverLessService.sendRequest(
          SendFileRequest(
            from: _authRepo.currentUserUid,
            to: to,
            fileUuid: uuid,
          ).writeToBuffer(),
          ip,
          type: SEND_FILE_REQ,
        );
        return true;
      }
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  Future<void> resendPendingPackets(Uid uid) async {
    await _sendPendingMessage(uid.asString());

    _pendingAck[uid.asString()]?.forEach((element) {
      _sendAck(element);
    });
    _pendingAck.clear();

    _pendingSeen[uid.asString()]?.forEach((element) {
      _sendSeen(element);
    });
    _pendingSeen.clear();
  }

  Future<void> _sendSeen(Seen seen) async {
    final ip = await _serverLessService.getIp(seen.to.asString());
    if (ip != null) {
      await _serverLessService.sendRequest(
        seen.writeToBuffer(),
        ip,
        type: SEEN,
      );
    }
  }

  Future<bool> sendFile({
    required String filePath,
    required Uid to,
    required String filename,
    required String uuid,
  }) async {
    final ip = await _serverLessService.getIp(to.asString());
    if (ip != null) {
      return _serverLessFileService.sendFile(
        filePath: filePath,
        receiverIp: ip,
        uuid: uuid,
        name: filename,
      );
    }
    return false;
  }

  Future<void> _processMessage(HttpRequest request) async {
    final message = Message.fromBuffer(await request.first);
    final ip = request.headers.value(IP);
    if (ip != null) {
      unawaited(
        _serverLessService.saveIp(uid: message.from.asString(), ip: ip),
      );
    }
    var uid = message.from;
    if (message.to.category == Categories.GROUP ||
        message.to.category == Categories.CHANNEL) {
      uid = message.to;
    }
    final room = await _roomDao.getRoom(uid);
    final ackId = message.id;
    if (!message.edited) {
      message.id =
          Int64(max((room?.lastMessageId ?? 0) + 1, message.id.toInt()));
    }
    unawaited(
      _dataStreamService.handleIncomingMessage(
        message,
        isOnlineMessage: true,
        isLocalNetworkMessage: true,
      ),
    );
    if (!message.edited) {
      unawaited(
        _sendAck(
          MessageDeliveryAck(
            to: message.from,
            packetId: message.packetId,
            time: Int64(
              DateTime.now().millisecondsSinceEpoch,
            ),
            id: ackId,
            from: _authRepo.currentUserUid,
          ),
        ),
      );
    }
    if (message.hasFile()) {
      final uuid = message.file.uuid;
      if (!await _serverLessFileService.checkIfFileExit(
        uuid: uuid,
      )) {
        _sendResendFileRequest(
          uuid: uuid,
          name: message.file.name,
          senderIp: request.headers.value(IP)!,
        );
      }
    }
  }

  void _sendResendFileRequest({
    required String uuid,
    required String name,
    required String senderIp,
  }) {
    _serverLessFileService.startFileServer();
    _serverLessService.sendRequest(
      ResendFileRequest(
        uuid: uuid,
        name: name,
      ).writeToBuffer(),
      senderIp,
      type: RESEND_FILE_REQ,
    );
  }

  Future<void> _sendAck(MessageDeliveryAck ack) async {
    final ip = await _serverLessService.getIp(ack.to.asString());
    if (ip != null) {
      await _serverLessService.sendRequest(
        ack.writeToBuffer(),
        ip,
        type: ACK,
      );
    } else {
      if (_pendingAck[ack.to.asString()] == null) {
        _pendingAck[ack.to.asString()] = [];
      }
      _pendingAck[ack.to.asString()]?.add(ack);
    }
  }

  Future<void> _sendCallEvent(
    call_pb.CallEventV2ByClient callEventV2ByClient,
  ) async {
    final ip =
        await _serverLessService.getIp(callEventV2ByClient.to.asString());
    if (ip != null) {
      final callEvent = CallEventV2()
        ..id = callEventV2ByClient.id
        ..to = callEventV2ByClient.to
        ..isVideo = callEventV2ByClient.isVideo
        ..from = _authRepo.currentUserUid
        ..time = Int64(DateTime.now().millisecondsSinceEpoch);
      if (callEventV2ByClient.hasRinging()) {
        callEvent.ringing = callEventV2ByClient.ringing;
      } else if (callEventV2ByClient.hasOffer()) {
        callEvent.offer = callEventV2ByClient.offer;
      } else if (callEventV2ByClient.hasEnd()) {
        callEvent.end = callEventV2ByClient.end;
      } else if (callEventV2ByClient.hasAnswer()) {
        callEvent.answer = callEventV2ByClient.answer;
      } else if (callEventV2ByClient.hasDecline()) {
        callEvent.decline = callEventV2ByClient.decline;
      } else if (callEventV2ByClient.hasBusy()) {
        callEvent.busy = callEventV2ByClient.busy;
      }
      await _serverLessService.sendRequest(
        callEvent.writeToBuffer(),
        ip,
        type: CALL_EVENT,
      );

      if (callEvent.hasRinging()) {
        _callService.addCallEvent(CallEvents.callEvent(callEvent));
      } else if (callEvent.hasBusy()) {
        unawaited(_sendCallLog(CallLog()..end = CallEventEnd()));
      }
    }
  }

  Future<void> _sendCallLog(CallLog callLog) async {}
}
