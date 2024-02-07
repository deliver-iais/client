// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/models/local_chat_room.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/serverless/serverless_file_service.dart';
import 'package:deliver/services/serverless/serverless_muc_service.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/utils/message_utils.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/server_less_packet.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
// import 'package:deliver/services/serverless/encryption.dart';






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
  final _rooms = <String, LocalChatRoom>{};
  final _messagePacketIdes = <String>{};


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
          ServerLessPacket(
            activity: Activity(
              from: _authRepo.currentUserUid,
              to: activity.to,
              typeOfActivity: activity.typeOfActivity,
            ),
          ),
          ip,
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
    _messagePacketIdes.add(message.packetId);
    if (to.category == Categories.USER) {
      final ip = await _serverLessService.getIp(to.asString());
      if (ip != null) {
        await _send(ip: ip, message: message);
      }
    } else if (to.category == Categories.GROUP ||
        to.category == Categories.CHANNEL) {
      unawaited(_serverLessMucService.sendMessage(message));
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
    if (message.whichType() != Message_Type.callLog &&
        message.to.category == Categories.USER) {
      Timer(
        const Duration(seconds: 3),
        () => _checkPendingStatus(
          message.packetId,
          to: to,
        ),
      );
    }
  }

  Future<void> _send({required String ip, required Message message}) async {
    try {
      final res = await _serverLessService.sendRequest(
          ServerLessPacket(message: message), ip);
      if (res != null && res.statusCode == HttpStatus.ok) {
        if (!message.edited && !message.hasCallLog()) {
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
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _checkPendingStatus(
    String packetId, {
    required Uid to,
  }) async {
    if (_messagePacketIdes.contains(packetId)) {
      _serverLessService
        ..removeIp(to.asString())
        ..sendBroadCast(to: to);
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

  Future<void> processIncomingPacket(ServerLessPacket serverLessPacket) async {
    try {
      switch (serverLessPacket.whichType()) {
        case ServerLessPacket_Type.messageDeliveryAck:
          unawaited(
            _handleAck(serverLessPacket.messageDeliveryAck),
          );
          break;
        case ServerLessPacket_Type.seen:
          unawaited(_dataStreamService.handleSeen(serverLessPacket.seen));
          break;
        case ServerLessPacket_Type.callEvent:
          final callEvents = CallEvents.callEvent(
            serverLessPacket.callEvent,
          );
          _callService
            ..addCallEvent(callEvents)
            ..shouldRemoveData = false;
          break;
        case ServerLessPacket_Type.message:
          // if(serverLessPacket.message.hasText()) {
          //   try {
          //     serverLessPacket.message.text.text = Encryption().decryptText(serverLessPacket.message.text.text);
          //   } catch (e) {
          //     _logger.e(e);
          //   }
          // }
          if (serverLessPacket.proxyMessage) {
            await _serverLessMucService
                .sendMessageToMucUsers(serverLessPacket.message);
          } else {
            await processMessage(serverLessPacket.message);
          }

          break;
        case ServerLessPacket_Type.createLocalMuc:
          await _serverLessMucService.handleCreateMuc(
            serverLessPacket.createLocalMuc,
            serverLessPacket.proxyMessage,
          );
          break;
        case ServerLessPacket_Type.addMembersReq:
          await _serverLessMucService.handleAddMember(
            serverLessPacket.addMembersReq,
            from: serverLessPacket.uid.asString(),
            name: serverLessPacket.name,
          );
          break;
        case ServerLessPacket_Type.activity:
          _dataStreamService.handleActivity(serverLessPacket.activity);
          break;
        case ServerLessPacket_Type.localNetworkInfo:
        case ServerLessPacket_Type.notSet:
          break;
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void removePendingFromCache(String uid, String packetId) {
    _pendingMessageMap[uid]
        ?.removeWhere((element) => element.packetId == packetId);
  }

  Future<void> sendPendingMessage(String uid) async {
    if (_pendingMessageMap.keys.contains(uid) &&
        _pendingMessageMap[uid] != null) {
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
      unawaited(_serverLessService.sendRequest(
        ServerLessPacket(seen: seen),
        ip,
      ));
    }
  }


  Future<void> processMessage(Message message) async {
    unawaited(_handleMessage(message));
  }

  Future<void> _handleMessage(Message message) async {
    var uid = message.from.asString();
    if (message.to.category == Categories.GROUP ||
        message.to.category == Categories.CHANNEL) {
      uid = message.to.asString();
    }
    final room = _rooms[uid] ??
        (((await _roomDao.getRoom(uid.asUid())) ?? Room(uid: uid.asUid()))
            .getLocalChat());

    final messageId = room.lastMessageId + 1;
    final lastLocalNetworkMessageId = room.lastLocalNetworkId + 1;
    unawaited(
      _processIncomingMessage(
        roomUid: uid.asUid(),
        message..id = Int64(messageId),
        lastLocalNetworkMessageId: lastLocalNetworkMessageId,
      ),
    );
    _rooms[uid] = (_rooms[uid] ?? (Room(uid: uid.asUid()).getLocalChat()))
      ..lastMessageId = messageId
      ..lastLocalNetworkId = lastLocalNetworkMessageId;
  }

  Future<void> _processIncomingMessage(
    Message message, {
    required Uid roomUid,
    required int lastLocalNetworkMessageId,
  }) async {
    if (!message.edited &&
        !message.hasCallLog() &&
        message.to.category == Categories.USER) {
      unawaited(
        _sendAck(
          MessageDeliveryAck(
            to: message.from,
            packetId: message.packetId,
            time: Int64(
              DateTime.now().millisecondsSinceEpoch,
            ),
            id: Int64(1),
            from: _authRepo.currentUserUid,
          ),
        ),
      );
    }
    if (await _messageDao.getMessageByPacketId(roomUid, message.packetId) ==
        null) {
      await _dataStreamService.handleIncomingMessage(
        message,
        isOnlineMessage: true,
        isLocalNetworkMessage: true,
      );
      await _roomDao.updateRoom(
        uid: roomUid,
        localNetworkMessageCount: 1,
        lastLocalNetworkMessageId: lastLocalNetworkMessageId,
      );
    }
    if (message.whichType() == Message_Type.callLog) {
      final callLog = CallLog(
        from: _authRepo.currentUserUid,
        to: roomUid,
        id: message.callLog.id,
        isVideo: message.callLog.isVideo,
      );
      final packetId = DateTime.now().millisecondsSinceEpoch.toString() +
          message.to.asString();

      if (message.callLog.hasDecline() && !message.callLog.decline.isCaller) {
        callLog.decline = message.callLog.decline;
        callLog.decline.isCaller = true;
        await (_reSendCallLog(callLog, packetId, callLog.to));
      } else if (message.callLog.hasBusy() && !message.callLog.busy.isCaller) {
        callLog.busy = message.callLog.busy;
        callLog.busy.isCaller = true;
        await (_reSendCallLog(callLog, packetId, callLog.to));
      } else if (message.callLog.hasEnd() && message.callLog.end.isCaller) {
        // callLog.end = message.callLog.end;
        // callLog.end.isCaller = false;
        // await (_reSendCallLog(callLog, packetId, callLog.to));
      } else {
        if (kDebugMode) {
          print("received");
        }
      }
    }
  }

  Future<void> _handleAck(MessageDeliveryAck messageDeliveryAck) async {
    try {
      _messagePacketIdes.remove(messageDeliveryAck.packetId);
      final uid = messageDeliveryAck.from;
      final room = _rooms[uid.asString()] ??
          (((await _roomDao.getRoom(uid)) ?? Room(uid: uid)).getLocalChat());
      if (room.lastPacketId != messageDeliveryAck.packetId) {
        final messageId = room.lastMessageId + 1;
        final localNetworkMessageId = room.lastLocalNetworkId + 1;
        unawaited(
          _dataStreamService.handleAckMessage(
            messageDeliveryAck..id = Int64(messageId),
            isLocalNetworkMessage: true,
            localNetworkMessageId: localNetworkMessageId,
          ),
        );
        _rooms[uid.asString()] =
            (_rooms[uid.asString()] ?? (Room(uid: uid).getLocalChat()))
              ..lastMessageId = messageId
              ..lastLocalNetworkId = localNetworkMessageId
              ..lastPacketId = messageDeliveryAck.packetId;
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void reset() {
    _rooms.clear();
    _pendingMessageMap.clear();
  }

  Future<void> _sendAck(MessageDeliveryAck ack) async {
    final ip = await _serverLessService.getIp(ack.to.asString());
    if (ip != null) {
      unawaited(_serverLessService.sendRequest(
        ServerLessPacket(messageDeliveryAck: ack),
        ip,
      ));
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
      unawaited(_sendCallEventReq(callEvent, ip));
    }
    unawaited(_processCallLog(callEvent));
  }

  Future<void> _sendCallEventReq(
    call_pb.CallEventV2 callEvent,
    String ip, {
    int maxTry = 3,
  }) async {
    final res = await _serverLessService.sendRequest(
      ServerLessPacket(callEvent: callEvent),
      ip,
    );
    if (maxTry > 0 && (res == null || res.statusCode! != HttpStatus.ok)) {
      if (maxTry > 0) {
        Timer(const Duration(milliseconds: 400), () {
          _sendCallEventReq(callEvent, ip, maxTry: maxTry - 1);
        });
      }
    }
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

  Future<void> _reSendCallLog(
    CallLog callLog,
    String packetId,
    Uid roomUid,
  ) async {
    final room = await _roomDao.getRoom(roomUid);
    final message = Message()
      ..from = callLog.from
      ..to = callLog.to
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
