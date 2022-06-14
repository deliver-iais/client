// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

class CoreServices {
  final _logger = GetIt.I.get<Logger>();
  final _grpcCoreService = GetIt.I.get<CoreServiceClient>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _dataStreamServices = GetIt.I.get<DataStreamServices>();
  final _messageDao = GetIt.I.get<MessageDao>();

  @visibleForTesting
  bool responseChecked = false;

  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  StreamController<ClientPacket>? _clientPacketStream;

  ResponseStream<ServerPacket>? _responseStream;

  Timer? _connectionTimer;

  var _lastPongTime = 0;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  final BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);

  Future<void> initStreamConnection() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print("connection change" + result.index.toString() + "\t" + result.name);
    });
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }
    startStream();
    startCheckerTimer();
    _connectionStatus.distinct().listen((event) {
      connectionStatus.add(event);
    });
  }

  void closeConnection() {
    _connectionStatus.add(ConnectionStatus.Disconnected);
    _clientPacketStream?.close();
    if (_connectionTimer != null) _connectionTimer!.cancel();
  }

  @visibleForTesting
  void startCheckerTimer() {
    sendPing();
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }

    responseChecked = false;
    _connectionTimer = Timer(Duration(seconds: backoffTime), () {
      if (!responseChecked) {
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }
        startStream();
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
  void startStream() {
    try {
      _clientPacketStream = StreamController<ClientPacket>();
      _responseStream = isWeb
          ? _grpcCoreService
              .establishServerSideStream(EstablishServerSideStreamReq())
          : _grpcCoreService.establishStream(_clientPacketStream!.stream);
      _responseStream!.listen((serverPacket) {
        _logger.d(serverPacket);

        gotResponse();
        switch (serverPacket.whichType()) {
          case ServerPacket_Type.message:
            _dataStreamServices.handleIncomingMessage(
              serverPacket.message,
              isOnlineMessage: true,
            );
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
      _logger.e(e);
      return startStream();
    }
  }

  Future<void> sendMessage(MessageByClient message) async {
    try {
      final clientPacket = ClientPacket()
        ..message = message
        ..id = clock.now().microsecondsSinceEpoch.toString();
      await _sendClientPacket(clientPacket);
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
      ..id = clock.now().microsecondsSinceEpoch.toString();
    _sendClientPacket(clientPacket, forceToSendEvenNotConnected: true);
  }

  void sendSeen(seen_pb.SeenByClient seen) {
    final clientPacket = ClientPacket()
      ..seen = seen
      ..id = seen.id.toString();
    _sendClientPacket(clientPacket);
  }

  void sendCallAnswer(call_pb.CallAnswerByClient callAnswerByClient) {
    final clientPacket = ClientPacket()
      ..callAnswer = callAnswerByClient
      ..id = callAnswerByClient.id;
    _sendClientPacket(clientPacket);
  }

  void sendCallOffer(call_pb.CallOfferByClient callOfferByClient) {
    final clientPacket = ClientPacket()
      ..callOffer = callOfferByClient
      ..id = callOfferByClient.id;
    _sendClientPacket(clientPacket);
  }

  void sendActivity(ActivityByClient activity, String id) {
    if (!_authRepo.isCurrentUser(activity.to.toString())) {
      final clientPacket = ClientPacket()
        ..activity = activity
        ..id = id;
      if (!_authRepo.isCurrentUser(activity.to.asString())) {
        _sendClientPacket(clientPacket);
      }
    }
  }

  Future<void> _sendClientPacket(
    ClientPacket packet, {
    bool forceToSendEvenNotConnected = false,
  }) async {
    try {
      if (isWeb ||
          _clientPacketStream == null ||
          _clientPacketStream!.isClosed) {
        await _grpcCoreService.sendClientPacket(packet);
      } else if (forceToSendEvenNotConnected ||
          _connectionStatus.value == ConnectionStatus.Connected) {
        _clientPacketStream!.add(packet);
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
