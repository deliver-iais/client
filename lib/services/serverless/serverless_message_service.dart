import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/message.dart' as model;
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
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
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
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
  final _roomDao = GetIt.I.get<RoomDao>();
  final _dataStreamService = GetIt.I.get<DataStreamServices>();
  final _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _serverLessFileService = GetIt.I.get<ServerLessFileService>();
  final _callService = GetIt.I.get<CallService>();
  final _serverLessService = GetIt.I.get<ServerLessService>();
  final _serverLessMucService = GetIt.I.get<ServerLessMucService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _logger = GetIt.I.get<Logger>();
  final Map<String, List<PendingMessage>> _pendingMessageMap = {};
  final _completerMap = <String, Completer>{};

  Future<void> sendClientPacket(ClientPacket clientPacket, {int? id}) async {
    switch (clientPacket.whichType()) {
      case ClientPacket_Type.message:
        if (clientPacket.message.hasText()) {
          await _sendTextMessage(
            clientPacket.message,
            id ?? 1,
            edited: id != null,
          );
        } else if (clientPacket.message.hasFile()) {
          await _sendFileMessage(clientPacket.message, 1);
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
        await _send(ip: ip, message: message);
      }
    } else if (to.category == Categories.GROUP ||
        to.category == Categories.CHANNEL) {
      final members = await GetIt.I.get<MucDao>().getAllMembers(to);
      for (final element in members) {
        final ip = await _serverLessService.getIp(element.memberUid.asString());
        if (ip != null) {
          await _send(ip: ip, message: message);
        }
      }
    }
    Timer(
      const Duration(seconds: 4),
      () => _checkPendingStatus(message.packetId, to: to, message: message),
    );
  }

  Future<void> _send({required String ip, required Message message}) async {
    final res =
        await _serverLessService.sendRequest(message.writeToBuffer(), ip);
    if (res != null && res.statusCode == HttpStatus.ok) {
      unawaited(
        _handleAck(
          MessageDeliveryAck(
            to: message.from,
            packetId: message.packetId,
            time: Int64(
              DateTime.now().millisecondsSinceEpoch,
            ),
            id: message.id,
            from: message.to,
          ),
        ),
      );
    }
  }

  Future<void> _checkPendingStatus(
    String packetId, {
    required Uid to,
    required Message message,
  }) async {
    final pm = await _pendingMessageDao.getPendingMessage(packetId);
    var hasBeenSent = false;
    if (pm != null) {
      if (!hasBeenSent) {
        hasBeenSent = true;
      }
      _serverLessService.sendBroadCast(to: pm.roomUid);
    }
  }

  // // await _pendingMessageDao.savePendingMessage(
  //         //   PendingMessage(
  //         //     roomUid: callLog.to,
  //         //     packetId: packetId,
  //         //     msg: model.Message(
  //         //       roomUid: roomUid,
  //         //       from: callLog.from,
  //         //       to: roomUid,
  //         //       packetId: packetId,
  //         //       time: DateTime.now().millisecondsSinceEpoch,
  //         //       json: callLog.writeToJson(),
  //         //       type: MessageType.CALL_LOG,
  //         //     ),
  //         //     status: SendingStatus.PENDING,
  //         //   ),
  //         // );

  Future<void> processRequest(HttpRequest request) async {
    try {
      final type = request.headers.value(TYPE) ?? MESSAGE;
      if (type == ACK) {
        unawaited(
            _handleAck(MessageDeliveryAck.fromBuffer(await request.first)));
      } else if (type == SEEN) {
        await _dataStreamService
            .handleSeen(Seen.fromBuffer(await request.first));
      } else if (type == MESSAGE) {
        await _processMessage(request);
      } else if (type == CREATE_MUC) {
        await _serverLessMucService.handleCreateMuc(
          CreateLocalMuc.fromBuffer(await request.first),
        );
      } else if (type == ADD_MEMBER_TO_MUC) {
        await _serverLessMucService.handleAddMember(
          AddMembersReq.fromBuffer(
            await request.first,
          ),
          from: request.headers.value(MUC_ADD_MEMBER_REQUESTER)!,
          name: request.headers.value(MUC_NAME)!,
        );
      } else if (type == ACTIVITY) {
        _dataStreamService
            .handleActivity(Activity.fromBuffer(await request.first));
      } else if (type == CALL_EVENT) {
        final callEvents = CallEvents.callEvent(
          CallEventV2.fromBuffer(await request.first),
        );
        _callService
          ..addCallEvent(callEvents)
          ..shouldRemoveData = false;
      }
      request.response.statusCode = HttpStatus.ok;
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      _logger.e(e);
    }
    await request.response.close();
  }

  void removePendingFromCache(String uid, String packetId) {
    _pendingMessageMap[uid]
        ?.removeWhere((element) => element.packetId == packetId);
  }

  Future<void> sendPendingMessage(String uid) async {
    if (_pendingMessageMap.keys.contains(uid)) {
      if (_pendingMessageMap[uid]!.isNotEmpty) {
        var pm = _pendingMessageMap[uid]!.last.msg;
        try {
          if (pm.type == MessageType.CALL_LOG) {
            unawaited(
              _sendCallLog(
                CallLog.fromJson(pm.json),
                pm.packetId,
                pm.roomUid,
              ),
            );
          } else {
            if (pm.type == MessageType.FILE) {
              final file = file_pb.File.fromJson(pm.json);
              final fileInfo = await GetIt.I.get<FileRepo>().uploadClonedFile(
                  file.uuid, file.name,
                  packetIds: [], uid: uid.asUid());
              if (fileInfo != null) {
                pm = pm.copyWith(json: fileInfo.writeToJson());
              }
            }
            await sendClientPacket(
              ClientPacket()
                ..message = MessageUtils.createMessageByClient(
                  pm,
                ),
            );
          }

          if (_pendingMessageMap[uid]?.isNotEmpty ?? false) {
            _pendingMessageMap[uid]?.removeLast();
          }
        } catch (e) {
          _logger.e(e);
        }
      }
    }
  }

  Future<void> resendPendingPackets(Uid uid) async {
    _pendingMessageMap[uid.asString()] =
        await _pendingMessageDao.getPendingMessages(uid.asString());
    await sendPendingMessage(uid.asString());

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
    unawaited(_handleMessage(message));
  }

  Future<void> _handleMessage(Message message) async {
    final uid = message.from.asString();
    var completer = _completerMap[uid];
    if (completer == null || completer.isCompleted) {
      completer = Completer();
      _completerMap[uid] = completer;
      await _processIncomingMessage(message);
      completer.complete();
    } else {
      await completer.future;
      await _handleMessage(message);
    }
  }

  Future<void> _processIncomingMessage(Message message) async {
    var uid = message.from;
    if (message.to.category == Categories.GROUP ||
        message.to.category == Categories.CHANNEL) {
      uid = message.to;
    }
    final room = await _roomDao.getRoom(uid);
    final ackId = message.id;
    if (!message.edited) {
      message.id = Int64(room?.lastMessageId ?? 0) + 1;
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
    if (await _messageDao.getMessageByPacketId(room!.uid, message.packetId) == null) {
      await _dataStreamService.handleIncomingMessage(
        message,
        isOnlineMessage: true,
        isLocalNetworkMessage: true,
      );
      await _roomDao.updateRoom(
        uid: room.uid,
        lastLocalNetworkMessageId: message.id.toInt(),
        localNetworkMessageCount: room.localNetworkMessageCount + 1,
      );
    }
  }

  Future<void> _handleAck(MessageDeliveryAck messageDeliveryAck) async {
    var completer = _completerMap[messageDeliveryAck.from.asString()];
    if (completer == null || completer.isCompleted) {
      completer = Completer();
      _completerMap[messageDeliveryAck.from.asString()] = completer;
      await _dataStreamService.handleAckMessage(
        messageDeliveryAck,
        isLocalNetworkMessage: true,
      );
      completer.complete();
    } else {
      await completer.future;
      await _handleAck(messageDeliveryAck);
    }
  }

  Future<void> updateRooms() async {
    for (final room in (await _roomDao.getLocalRooms())) {
      await _roomDao.updateRoom(
        uid: room.uid,
        localNetworkMessageCount: 0,
        lastLocalNetworkMessageId: room.lastMessageId,
      );
    }
  }

  Future<void> _sendAck(MessageDeliveryAck ack) async {
    final ip = await _serverLessService.getIp(ack.to.asString());
    if (ip != null) {
      await _serverLessService.sendRequest(
        ack.writeToBuffer(),
        ip,
        type: ACK,
      );
    }
  }

  Future<void> _sendCallEvent(
    call_pb.CallEventV2ByClient callEventV2ByClient,
  ) async {
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
    final ip =
        await _serverLessService.getIp(callEventV2ByClient.to.asString());
    if (ip != null) {
      await _serverLessService.sendRequest(
        callEvent.writeToBuffer(),
        ip,
        type: CALL_EVENT,
      );
    }
    unawaited(_processCallLog(callEvent));
  }

  Future<void> _processCallLog(CallEventV2 callEvent) async {
    call_pb.CallLog? callLog;
    switch (callEvent.whichType()) {
      case call_pb.CallEventV2_Type.offer:
      case call_pb.CallEventV2_Type.ringing:
      case call_pb.CallEventV2_Type.answer:
        break;
      case call_pb.CallEventV2_Type.end:
        callLog = CallLog(
          from: callEvent.from,
          to: callEvent.to,
          id: callEvent.id,
          isVideo: callEvent.isVideo,
          end: callEvent.end,
        );
        break;
      case call_pb.CallEventV2_Type.decline:
        callLog = CallLog(
          from: callEvent.from,
          to: callEvent.to,
          id: callEvent.id,
          isVideo: callEvent.isVideo,
          decline: callEvent.decline,
        );
        break;
      case call_pb.CallEventV2_Type.busy:
        callLog = CallLog(
          from: callEvent.from,
          to: callEvent.to,
          id: callEvent.id,
          isVideo: callEvent.isVideo,
          busy: callEvent.busy,
        );
        break;
      case call_pb.CallEventV2_Type.notSet:
        break;
    }
    if (callLog != null) {
      final roomUid = callEvent.to;
      final packetId =
          DateTime.now().millisecondsSinceEpoch.toString() + roomUid.asString();
      unawaited(_sendCallLog(callLog, packetId, roomUid));
    }
  }

  Future<void> _sendCallLog(
    CallLog callLog,
    String packetId,
    Uid roomUid,
  ) async {
    final room = await _roomDao.getRoom(roomUid);
    final message = Message()
      ..from = _authRepo.currentUserUid
      ..to = roomUid
      ..packetId = packetId
      ..id = Int64(room != null ? room.lastMessageId + 1 : 1)
      ..callLog = callLog
      ..time = Int64(
        DateTime.now().millisecondsSinceEpoch,
      );
    await _sendMessage(
      to: roomUid,
      message: message,
    );
  }
}
