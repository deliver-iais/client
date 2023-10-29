import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:deliver/box/dao/local_network-conneaction_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/local_network_file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/register.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dio/dio.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ServerLessService {
  final Dio _dio = Dio();

  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _dataStreamService = GetIt.I.get<DataStreamServices>();
  final Map<String, String> _address = {};
  final _roomDao = GetIt.I.get<RoomDao>();
  final _localNetworkConnectionDao = GetIt.I.get<LocalNetworkConnectionDao>();

  final _serverLessFileService = GetIt.I.get<ServerLessFileService>();

  final Map<String, List<ClientPacket>> _pendingClientPacket = {};
  final Map<String, List<MessageDeliveryAck>> _pendingAck = {};

  var _ip = "";

  RawDatagramSocket? _upSocket;

  void start() {
    _localNetworkConnectionDao.deleteAll();
    _startServices();
  }

  void dispose() {}

  Future<void> _startServices() async {
    await _getMyLocalIp();
    await _startBroadcast();
    _sendBroadCast();
    unawaited(_startHttpService());
  }

  Future<void> _startBroadcast() async {
    await RawDatagramSocket.bind(InternetAddress.anyIPv4, UDP_PORT)
        .then((udpSocket) {
      _upSocket = udpSocket;
      udpSocket
        ..broadcastEnabled = true
        ..listen((_) {
          final data = udpSocket.receive()?.data;
          if (data != null) {
            _handleBroadCastMessage(data);
          }
        });
    });
  }

  void _sendBroadCast({Uid? to}) {
    _upSocket?.send(
      LocalNetworkRegisterReq(from: _authRepo.currentUserUid, to: to, url: _ip)
          .writeToBuffer(),
      InternetAddress(DESTINATION_ADDRESS),
      UDP_PORT,
    );
  }

  Future<void> _handleBroadCastMessage(Uint8List data) async {
    try {
      final registrationReq = LocalNetworkRegisterReq.fromBuffer(data);

      await _saveIp(
        uid: registrationReq.from.asString(),
        ip: registrationReq.url,
      );
      // _sendBroadCast();
      _resendPendingPackets(registrationReq.from);
      if (registrationReq.to
          .isSameEntity(_authRepo.currentUserUid.asString())) {
        await _sendMyAddress(registrationReq.url);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _sendMyAddress(String url) async {
    try {
      await _dio.get(
        "http://$url:$SERVER_PORT?from=${_authRepo.currentUserUid.node}&address=$_ip",
        options: Options(
          headers: {TYPE: REGISTER},
        ),
      );
    } catch (e) {
      _logger.e(e);
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
    final ip = await getIp(messageByClient.to.asString());
    if (ip != null) {
      unawaited(_sendRequest(message.writeToBuffer(), ip));
    }
  }

  Future<void> _sendTextMessage(
    MessageByClient messageByClient,
    int id,
  ) async {
    final message = Message()
      ..from = _authRepo.currentUserUid
      ..to = messageByClient.to
      ..packetId = messageByClient.packetId
      ..replyToId = messageByClient.replyToId
      ..id = Int64(id)
      ..text = messageByClient.text
      ..forwardFrom = messageByClient.forwardFrom
      ..time = Int64(
        DateTime.now().millisecondsSinceEpoch,
      );
    final ip = await getIp(messageByClient.to.asString());
    if (ip != null) {
      unawaited(_sendRequest(message.writeToBuffer(), ip));
    }
  }

  void _resendPendingPackets(Uid uid) {
    _pendingClientPacket[uid.asString()]?.forEach((element) async {
      await sendClientPacket(element);
    });
    _pendingAck[uid.asString()]?.forEach((element) {
      _sendAck(element);
    });
  }

  Future<void> _sendRequest(
    Uint8List reqData,
    String url, {
    String type = "Message",
  }) async {
    try {
      unawaited(
        _dio.post(
          "http://$url:$SERVER_PORT",
          data: reqData,
          options: Options(
            headers: {TYPE: type},
            contentType: ContentType.binary.mimeType,
          ),
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _sendSeen(Seen seen) async {
    final ip = await getIp(seen.to.asString());
    if (ip != null) {
      await _sendRequest(
        seen.writeToBuffer(),
        ip,
        type: SEEN,
      );
    }
  }

  Future<void> _sendAck(MessageDeliveryAck ack) async {
    final ip = await getIp(ack.to.asString());
    if (ip != null) {
      await _sendRequest(
        ack.writeToBuffer(),
        ip,
        type: ACK,
      );
    } else {
      _sendBroadCast(to: ack.to);
      if (_pendingAck[ack.to.asString()] == null) {
        _pendingAck[ack.to.asString()] = [];
      }
      _pendingAck[ack.to.asString()]?.add(ack);
    }
  }

  Future<void> _startHttpService() async {
    try {
      final server = await HttpServer.bind(_ip, SERVER_PORT);
      _logger.i('Listening on $_ip:${server.port}');

      await for (final HttpRequest request in server) {
        try {
          final type = request.headers.value(TYPE) ?? "Message";

          if (type == REGISTER) {
            final from = request.uri.queryParameters['from'];
            final address = request.uri.queryParameters['address'];
            _logger
              ..i(from)
              ..i(address);
            final uid = Uid()..node = from!;
            await _saveIp(uid: uid.asString(), ip: address!);
            _resendPendingPackets(uid);
          } else if (type == ACK) {
            unawaited(
              _dataStreamService.handleAckMessage(
                MessageDeliveryAck.fromBuffer(await request.first),
              ),
            );
          } else if (type == SEEN) {
            unawaited(
              _dataStreamService
                  .handleSeen(Seen.fromBuffer(await request.first)),
            );
          } else if (type == SEND_FILE_REQ) {
            final sendFileRequest =
                SendFileRequest.fromBuffer(await request.first);
            unawaited(
              _serverLessFileService.startFileServer(
                _ip,
                lastRequestedFileUuid: sendFileRequest.fileUuid,
              ),
            );
          } else if (type == "Message") {
            final message = Message.fromBuffer(await request.first);
            final room = await _roomDao.getRoom(message.from);
            message.id =
                Int64(max(room?.lastMessageId ?? 0 + 1, message.id.toInt()));
            unawaited(
              _dataStreamService.handleIncomingMessage(
                message,
                isOnlineMessage: true,
              ),
            );

            unawaited(
              _sendAck(
                MessageDeliveryAck(
                  to: message.from,
                  packetId: message.packetId,
                  time: Int64(
                    DateTime.now().millisecondsSinceEpoch,
                  ),
                  id: Int64(
                    message.id.toInt(),
                  ),
                  from: _authRepo.currentUserUid,
                ),
              ),
            );
            _logger.i(message.text.text);
          } else if (type == "File") {
            _logger.i("new File..........");
            var res = await request.first;
            _logger.i(res.length);
          }
        } catch (e) {
          _logger.e(e);
        }
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendClientPacket(ClientPacket clientPacket) async {
    switch (clientPacket.whichType()) {
      case ClientPacket_Type.message:
        final uid = clientPacket.message.to;
        final ip = await getIp(uid.asString());
        if (ip != null) {
          final room = await _roomDao.getRoom(clientPacket.message.to);
          if (clientPacket.message.hasText()) {
            unawaited(
              _sendTextMessage(
                clientPacket.message,
                room != null ? room.lastMessageId + 1 : 1,
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
        } else {
          _sendBroadCast(to: uid);
          if (_pendingClientPacket[uid.asString()] == null) {
            _pendingClientPacket[uid.asString()] = [];
          }
          _pendingClientPacket[uid.asString()]!.add(clientPacket);
        }
        break;
      case ClientPacket_Type.seen:
        final uid = clientPacket.seen.to;
        if (await getIp(uid.asString()) != null) {
          unawaited(
            _sendSeen(
              Seen()
                ..to = clientPacket.seen.to
                ..from = _authRepo.currentUserUid
                ..id = clientPacket.seen.id,
            ),
          );
        } else {
          _sendBroadCast(to: uid);
          if (_pendingClientPacket[uid.asString()] == null) {
            _pendingClientPacket[uid.asString()] = [];
          }
          _pendingClientPacket[uid.asString()]!.add(clientPacket);
        }
        break;
      case ClientPacket_Type.activity:
      case ClientPacket_Type.ping:
      case ClientPacket_Type.callOffer:
      case ClientPacket_Type.callAnswer:
      case ClientPacket_Type.callEvent:
      case ClientPacket_Type.notSet:
        break;
    }
  }

  Future<bool> sendFile({
    required String filePath,
    required Uid to,
    required String filename,
    required String uuid,
  }) async {
    final ip = await getIp(to.asString());
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

  Future<void> sendFileRequest(Uid to, String uuid) async {
    final ip = await getIp(to.asString());
    if (ip != null) {
      await _sendRequest(
        SendFileRequest(
          to: to,
          from: _authRepo.currentUserUid,
          fileUuid: uuid,
        ).writeToBuffer(),
        ip,
        type: SEND_FILE_REQ,
      );
    }
  }

  Future<void> _getMyLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: true,
    );

    if (Platform.isAndroid) {
      _ip = interfaces.last.addresses.first.address;
    } else {
      _ip = interfaces
          .where((e) => e.name.contains("Wi"))
          .first
          .addresses
          .first
          .address;
    }

    _logger.i("/////////////  " "\t$_ip");
  }

  Future<void> uploadFile({required String path, required Uid to}) async {
    try {} catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _saveIp({required String uid, required String ip}) async {
    try {
      _address[uid] = ip;
      unawaited(_localNetworkConnectionDao.save(
        LocalNetworkConnections(
          uid: uid.asUid(),
          ip: ip,
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
        ),
      ));
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<String?> getIp(String uid) async {
    try {
      if (_address[uid] != null) {
        return _address[uid];
      }
      return (await _localNetworkConnectionDao.get(uid.asUid()))?.ip;
    } catch (e) {
      _logger.e(e);
    }
    return null;
  }
}
