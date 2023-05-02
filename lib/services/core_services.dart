import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatus { Connected, Disconnected, Connecting }

final disconnectedTime = BehaviorSubject.seeded(0);
final connectionError = BehaviorSubject.seeded("");

const MIN_BACKOFF_TIME = isWeb ? 16 : 4;
final MAX_BACKOFF_TIME = isMobileNative ? 16 : 64;
const BACKOFF_TIME_INCREASE_RATIO = 2;

class CoreServices {
  final _logger = GetIt.I.get<Logger>();
  final _services = GetIt.I.get<ServicesDiscoveryRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _dataStreamServices = GetIt.I.get<DataStreamServices>();
  final _analyticRepo = GetIt.I.get<AnalyticsRepo>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _uptimeStartTime = BehaviorSubject.seeded(0);
  final _reconnectCount = BehaviorSubject.seeded(0);

  @visibleForTesting
  bool responseChecked = false;

  bool _disconnected = false;

  @visibleForTesting
  int backoffTime = MIN_BACKOFF_TIME;

  StreamController<ClientPacket>? _clientPacketStream;

  ResponseStream<ServerPacket>? _responseStream;

  Timer? _connectionTimer;

  Timer? _disconnectedTimer;

  var _lastPongTime = 0;

  var _lastRoomMetadataUpdateTime = settings.lastRoomMetadataUpdateTime.value;

  int get lastRoomMetadataUpdateTime => _lastRoomMetadataUpdateTime;

  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  final BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);

  void retryConnection({bool forced = false}) {
    if (!forced && _connectionStatus.value != ConnectionStatus.Disconnected) {
      return;
    }
    _connectionTimer?.cancel();
    // _responseStream?.cancel();
    _connectionStatus.add(ConnectionStatus.Connecting);
    startStream();
    startCheckerTimer();
  }

  void fasterRetryConnection() {
    backoffTime = MIN_BACKOFF_TIME;
    retryConnection();
  }

  Future<void> initStreamConnection() async {
    retryConnection();
    _connectionStatus.distinct().listen((event) {
      connectionStatus.add(event);
    });

    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        retryConnection(forced: true);
      } else {
        _onConnectionError();
      }
    });
  }

  void closeConnection() {
    try {
      _connectionStatus.add(ConnectionStatus.Disconnected);
      _clientPacketStream?.close();
      if (_connectionTimer != null) _connectionTimer!.cancel();
      _uptimeStartTime.add(0);
    } catch (e) {
      _logger.e(e);
    }
  }

  ValueStream<int> get uptimeStartTime => _uptimeStartTime;

  ValueStream<int> get reconnectCount => _reconnectCount;

  @visibleForTesting
  void startCheckerTimer() {
    sendPing();
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }
    responseChecked = false;
    _connectionTimer = Timer(Duration(seconds: backoffTime), () {
      if (!responseChecked) {
        if (backoffTime >= BACKOFF_TIME_INCREASE_RATIO * MIN_BACKOFF_TIME) {
          _onConnectionError();
        }
        _disconnected = true;
        if (backoffTime <= MAX_BACKOFF_TIME / BACKOFF_TIME_INCREASE_RATIO) {
          backoffTime *= BACKOFF_TIME_INCREASE_RATIO;
        } else {
          backoffTime = MIN_BACKOFF_TIME;
        }

        retryConnection(forced: true);
      }
      startCheckerTimer();
    });
  }

  void checkConnectionTimer() {
    if (_connectionTimer != null && !_connectionTimer!.isActive) {
      retryConnection(forced: true);
    }
  }

  void gotResponse({required bool isPong}) {
    _disconnected = false;
    try {
      _disconnectedTimer?.cancel();
    } catch (_) {}
    if (isPong || _lastPongTime != 0) {
      _connectionStatus.add(ConnectionStatus.Connected);
    }

    backoffTime = MIN_BACKOFF_TIME;
    responseChecked = true;
    disconnectedTime.add(0);
    connectionError.add("");
    if (_uptimeStartTime.value == 0) {
      _reconnectCount.add(_reconnectCount.value + 1);
      _uptimeStartTime.add(clock.now().millisecondsSinceEpoch);
    }
  }

  @visibleForTesting
  void startStream() {
    try {
      _clientPacketStream = StreamController<ClientPacket>();
      _responseStream = isWeb
          ? _services.coreServiceClient.establishServerSideStream(
              EstablishServerSideStreamReq(),
            )
          : _services.coreServiceClient.establishStream(
              _clientPacketStream!.stream.map((event) {
                _analyticRepo.incCSF("client/${event.whichType().name}");

                return event;
              }),
            );

      _responseStream?.listen(
        (serverPacket) {
          try {
            _logger.d(serverPacket);

            _analyticRepo.incCSF("server/${serverPacket.whichType().name}");

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
                _lastRoomMetadataUpdateTime =
                    serverPacket.pong.lastRoomMetadataUpdateTime.toInt();
                //update last message delivery ack on sharedPref
                final latMessageDeliveryAck =
                    serverPacket.pong.lastMessageDeliveryAck;

                settings.lastMessageDeliveryAck.set(latMessageDeliveryAck);
                break;
              case ServerPacket_Type.liveLocationStatusChanged:
              case ServerPacket_Type.error:
                // TODO(hasan): Handle these cases, https://gitlab.iais.co/deliver/wiki/-/issues/411
                break;
              case ServerPacket_Type.notSet:
              case ServerPacket_Type.expletivePacket:
                break;
              case ServerPacket_Type.callEvent:
                // TODO: Handle this case.
                break;
            }
          } catch (_) {}
          gotResponse(isPong: serverPacket.hasPong());
        },
        onError: (e) {
          _logger.e(e);
          _onConnectionError();
          connectionError.add(e.toString());
        },
      );
    } catch (e) {
      _onConnectionError();
      connectionError.add(e.toString());
      _logger.e(e);
    }
  }

  void _onConnectionError() {
    _disconnected = true;
    if (_disconnectedTimer == null || !_disconnectedTimer!.isActive) {
      _disconnectedTimer = Timer(Duration(seconds: 2 * backoffTime), () {
        _changeStateToDisconnected();
      });
    }
  }

  void _changeStateToDisconnected() {
    _connectionStatus.add(ConnectionStatus.Disconnected);
    disconnectedTime.add(backoffTime - 1);
    _uptimeStartTime.add(0);
  }

  Future<void> sendMessage(MessageByClient message) async {
    try {
      final clientPacket = ClientPacket()
        ..message = message
        ..id = clock.now().microsecondsSinceEpoch.toString();
      await _sendClientPacket(clientPacket);
      if (_connectionStatus.value == ConnectionStatus.Connected) {
        Timer(
          const Duration(seconds: MIN_BACKOFF_TIME ~/ 2),
          () => _checkPendingStatus(message.packetId),
        );
      }
      _changeAppToDisconnectedAfterSendMessage();
    } catch (e) {
      _changeAppToDisconnectedAfterSendMessage();
      _logger.e(e);
    }
  }

  void _changeAppToDisconnectedAfterSendMessage() {
    if (_disconnected ||
        (_disconnectedTimer != null && _disconnectedTimer!.isActive)) {
      _changeStateToDisconnected();
    }
  }

  Future<void> _checkPendingStatus(String packetId) async {
    final pm = await _messageDao.getPendingMessage(packetId);
    if (pm != null) {
      await _messageDao.savePendingMessage(
        pm.copyWith(
          failed: _connectionStatus.value == ConnectionStatus.Connected,
        ),
      );
    }
  }

  void sendPing() {
    final ping = Ping()..lastPongTime = Int64(_lastPongTime);
    final clientPacket = ClientPacket()
      ..ping = ping
      ..id = clock.now().microsecondsSinceEpoch.toString();
    _sendClientPacket(clientPacket, forceToSendEvenNotConnected: true);
    FlutterForegroundTask.saveData(
      key: "BackgroundActivationTime",
      value: (clock.now().millisecondsSinceEpoch + backoffTime * 3 * 1000)
          .toString(),
    );
    FlutterForegroundTask.saveData(key: "AppStatus", value: "Opened");
    FlutterForegroundTask.saveData(
      key: "Language",
      value: GetIt.I.get<I18N>().locale.languageCode,
    );
  }

  Future<void> sendSeen(seen_pb.SeenByClient seen) async {
    await _analyticsService.sendLogEvent(
      "sendSeen",
    );
    final clientPacket = ClientPacket()
      ..seen = seen
      ..id = seen.id.toString();
    await _sendClientPacket(clientPacket)
        .onError(
          (error, stackTrace) async => {
            await _analyticsService.sendLogEvent(
              "failedSeen",
              parameters: {
                'error': error.toString(),
              },
            )
          },
        )
        .then(
          (value) async => {
            await _analyticsService.sendLogEvent(
              "successSeen",
            ),
          },
        );
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
        await _services.coreServiceClient.sendClientPacket(packet);
      } else if (forceToSendEvenNotConnected ||
          _connectionStatus.value == ConnectionStatus.Connected) {
        _clientPacketStream!.add(packet);
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
