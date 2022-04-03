// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatus { Connected, Disconnected, Connecting }

const MIN_BACKOFF_TIME = isWeb ? 16 : 4;
const MAX_BACKOFF_TIME = isWeb ? 16 : 8;
const BACKOFF_TIME_INCREASE_RATIO = 2;

// TODO Change to StreamRepo, it is not a service, it is repo now!!!
class CoreServices {
  final _logger = GetIt.I.get<Logger>();
  final _grpcCoreService = GetIt.I.get<CoreServiceClient>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _dataStreamServices = GetIt.I.get<DataStreamServices>();
  final _messageDao = GetIt.I.get<MessageDao>();

  Timer? _connectionTimer;
  var _lastPongTime = 0;

  @visibleForTesting
  bool responseChecked = false;

  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  late StreamController<ClientPacket> _clientPacketStream;

  late ResponseStream<ServerPacket> _responseStream;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  final BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  //TODO test
  Future<void> initStreamConnection() async {
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }
    await startStream();
    startCheckerTimer();
    _connectionStatus.distinct().listen((event) {
      connectionStatus.add(event);
    });
  }

  void closeConnection() {
    _connectionStatus.add(ConnectionStatus.Disconnected);
    _clientPacketStream.close();
    if (_connectionTimer != null) _connectionTimer!.cancel();
  }

  @visibleForTesting
  Future<void> startCheckerTimer() async {
    sendPing();
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }

    responseChecked = false;
    _connectionTimer = Timer(Duration(seconds: backoffTime), () async {
      if (!responseChecked) {
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }
        await startStream();
        _connectionStatus.add(ConnectionStatus.Disconnected);
      }

      startCheckerTimer();
    });
  }

  void gotResponse() {
    _connectionStatus.add(ConnectionStatus.Connected);
    backoffTime = MIN_BACKOFF_TIME;
    responseChecked = true;
  }

  @visibleForTesting
  Future<void> startStream() async {
    try {
      _clientPacketStream = StreamController<ClientPacket>();
      _responseStream = isWeb
          ? _grpcCoreService
              .establishServerSideStream(EstablishServerSideStreamReq())
          : _grpcCoreService.establishStream(_clientPacketStream.stream);
      _responseStream.listen((serverPacket) async {
        _logger.d(serverPacket);

        gotResponse();
        switch (serverPacket.whichType()) {
          case ServerPacket_Type.message:
            _dataStreamServices.handleIncomingMessage(serverPacket.message);
            break;
          case ServerPacket_Type.messageDeliveryAck:
            _dataStreamServices
                .handleAckMessage(serverPacket.messageDeliveryAck);
            break;
          case ServerPacket_Type.seen:
            _dataStreamServices.handleSeen(serverPacket.seen);
            break;
          case ServerPacket_Type.activity:
            _dataStreamServices.handleActivity(serverPacket.activity);
            break;
          case ServerPacket_Type.roomPresenceTypeChanged:
            _dataStreamServices.handleRoomPresenceTypeChange(
              serverPacket.roomPresenceTypeChanged,
            );
            break;
          case ServerPacket_Type.callOffer:
            _dataStreamServices.handleCallOffer(serverPacket.callOffer);
            break;
          case ServerPacket_Type.callAnswer:
            _dataStreamServices.handleCallAnswer(serverPacket.callAnswer);
            break;
          case ServerPacket_Type.pong:
            _lastPongTime = serverPacket.pong.serverTime.toInt();
            break;
          case ServerPacket_Type.liveLocationStatusChanged:
          case ServerPacket_Type.error:
            // TODO(hasan): Handle these cases, https://gitlab.iais.co/deliver/wiki/-/issues/411
            break;
          case ServerPacket_Type.notSet:
          case ServerPacket_Type.expletivePacket:
            break;
        }
      });
    } catch (e) {
      await startStream();
      _logger.e(e);
    }
  }

  Future<void> sendMessage(MessageByClient message) async {
    try {
      final clientPacket = ClientPacket()
        ..message = message
        ..id = DateTime.now().microsecondsSinceEpoch.toString();
      _sendPacket(clientPacket);
      Timer(
        const Duration(seconds: MIN_BACKOFF_TIME ~/ 2),
        () => _checkPendingStatus(message.packetId),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _checkPendingStatus(String packetId) async {
    final pm = await _messageDao.getPendingMessage(packetId);
    if (pm != null) {
      await _messageDao.savePendingMessage(
        pm.copyWith(
          failed: true,
        ),
      );
      if (_connectionStatus.value == ConnectionStatus.Connected) {
        connectionStatus.add(ConnectionStatus.Connected);
      }
    }
  }

  void sendPing() {
    final ping = Ping()..lastPongTime = Int64(_lastPongTime);
    final clientPacket = ClientPacket()
      ..ping = ping
      ..id = DateTime.now().microsecondsSinceEpoch.toString();
    _sendPacket(clientPacket, forceToSend: true);
  }

  void sendSeen(seen_pb.SeenByClient seen) {
    final clientPacket = ClientPacket()
      ..seen = seen
      ..id = seen.id.toString();
    _sendPacket(clientPacket);
  }

  void sendCallAnswer(call_pb.CallAnswerByClient callAnswerByClient) {
    final clientPacket = ClientPacket()
      ..callAnswer = callAnswerByClient
      ..id = callAnswerByClient.id;
    _sendPacket(clientPacket);
  }

  void sendCallOffer(call_pb.CallOfferByClient callOfferByClient) {
    final clientPacket = ClientPacket()
      ..callOffer = callOfferByClient
      ..id = callOfferByClient.id;
    _sendPacket(clientPacket);
  }

  void sendActivity(ActivityByClient activity, String id) {
    if (!_authRepo.isCurrentUser(activity.to.toString())) {
      final clientPacket = ClientPacket()
        ..activity = activity
        ..id = id;
      if (!_authRepo.isCurrentUser(activity.to.asString())) {
        _sendPacket(clientPacket);
      }
    }
  }

  Future<void> _sendPacket(
    ClientPacket packet, {
    bool forceToSend = false,
  }) async {
    try {
      if (isWeb) {
        await _grpcCoreService.sendClientPacket(packet);
      } else if (!_clientPacketStream.isClosed &&
          (forceToSend ||
              _connectionStatus.value == ConnectionStatus.Connected)) {
        _clientPacketStream.add(packet);
      } else {
        await startStream();
        // throw Exception("no active stream");
      }
    } catch (e) {
      _logger.e(e);
      // rethrow;
    }
  }
}
