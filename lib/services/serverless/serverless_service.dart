import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:deliver/box/dao/local_network-connection_dao.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_file_service.dart';
import 'package:deliver/services/serverless/serverless_message_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/register.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ServerLessService {
  final Dio _dio = Dio();
  final _networkInfo = NetworkInfo();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();
  final Map<String, String> _address = {};
  final _localNetworkConnectionDao = GetIt.I.get<LocalNetworkConnectionDao>();
  final _serverLessFileService = GetIt.I.get<ServerLessFileService>();
  var _ip = "";
  HttpServer? _httpServer;

  RawDatagramSocket? _upSocket;

  var _wifiBroadcast = "255.255.255.255";

  void start() {
    _address.clear();
    // _notificationForegroundService.localNetworkForegroundServiceStart();
    _startServices();
  }

  Future<void> restart() async {
    await dispose();
    _serverLessFileService.dispose();
    start();
  }

  Future<void> dispose() async {
    await _httpServer?.close(force: true);
    _upSocket?.close();
  }

  String getBroadcastIp() => _wifiBroadcast;

  Future<void> _clearConnections() async {
    _address.clear();
    await _localNetworkConnectionDao.deleteAll();
  }

  @pragma('vm:entry-point')
  Future<void> _startServices() async {
    // unawaited(GetIt.I.get<ServerLessMessageService>().updateRooms());
    if (await _getMyLocalIp()) {
      await _clearConnections();
    }
    _startUdpListener();
    await _initWifiBroadcast();
    await _startHttpService();
  }

  void _startUdpListener({bool retry = true}) {
    try {
      _upSocket?.close();
      RawDatagramSocket.bind(InternetAddress.anyIPv4, UDP_PORT)
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
    } catch (e) {
      _logger.e(e);
      if (retry) {
        _startUdpListener(retry: false);
      }
    }
  }

  void sendBroadCast({
    Uid? to,
  }) {
    try {
      _upSocket?.send(
        LocalNetworkInfo(
          from: _authRepo.currentUserUid,
          to: to,
          url: _ip,
        ).writeToBuffer(),
        InternetAddress(_wifiBroadcast),
        UDP_PORT,
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _handleBroadCastMessage(Uint8List data) async {
    try {
      final registrationReq = LocalNetworkInfo.fromBuffer(data);
      if (!registrationReq.from
          .isSameEntity(_authRepo.currentUserUid.asString())) {
        await saveIp(
          uid: registrationReq.from.asString(),
          ip: registrationReq.url,
        );
        _logger.i("new address....${registrationReq.url} +??? $_ip");
        unawaited(
          GetIt.I
              .get<ServerLessMessageService>()
              .resendPendingPackets(registrationReq.from),
        );
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

  Future<void> sendRequest(
    Uint8List reqData,
    String url, {
    String type = MESSAGE,
    String from = "",
    String name = "",
  }) async {
    try {
      unawaited(
        _dio.post(
          "http://$url:$SERVER_PORT",
          data: reqData,
          options: Options(
            headers: {
              TYPE: type,
              IP: _ip,
              MUC_ADD_MEMBER_REQUESTER: from,
              MUC_NAME: name,
            },
            contentType: ContentType.binary.mimeType,
          ),
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _startHttpService() async {
    try {
      await _httpServer?.close(force: true);
      _httpServer = await HttpServer.bind(_ip, SERVER_PORT);
      _logger.i('Listening on $_ip:${_httpServer?.port}');
      if (_httpServer != null) {
        _httpServer?.listen((request) {
          try {
            final type = request.headers.value(TYPE) ?? MESSAGE;
            if (type == REGISTER) {
              unawaited(_processRegister(request));
            } else {
              unawaited(
                GetIt.I.get<ServerLessMessageService>().processRequest(request),
              );
            }
          } catch (e) {
            _logger.e(e);
          }
        });
      } else {
        await _reset();
      }
    } catch (e) {
      await _reset();
      _logger.e(e);
    }
    sendBroadCast();
  }

  Future<void> _reset() async {
    await _httpServer?.close(force: true);
    await _startHttpService();
  }

  Future<void> _processRegister(HttpRequest request) async {
    final from = request.uri.queryParameters['from'];
    final address = request.uri.queryParameters['address'];
    _logger.i("new address....$address +??? $_ip");

    final uid = Uid()..node = from!;
    await saveIp(uid: uid.asString(), ip: address!);
    unawaited(
      GetIt.I.get<ServerLessMessageService>().resendPendingPackets(uid),
    );
  }

  Future<bool> _getMyLocalIp() async {
    var needToClearConnections = false;
    var newIp = "";
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: true,
    );

    if (Platform.isAndroid) {
      newIp = interfaces.last.addresses.first.address;
    } else {
      newIp = interfaces
          .where((e) => e.name.contains("Wi"))
          .first
          .addresses
          .first
          .address;
    }
    if (_ip != newIp) {
      needToClearConnections = true;
    }
    _ip = newIp;
    _logger.i("///////////// " "\t$_ip");

    return needToClearConnections;
  }

  Future<void> saveIp({required String uid, required String ip}) async {
    try {
      _address[uid] = ip;
      unawaited(
        _localNetworkConnectionDao.save(
          LocalNetworkConnections(
            uid: uid.asUid(),
            ip: ip,
            lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _initWifiBroadcast() async {
    if (!settings.useDefaultUdpAddress.value) {
      try {
        final wifi = await _networkInfo.getWifiBroadcast();
        if (wifi != null) {
          _wifiBroadcast = wifi;
        } else {
          final s = _ip.split(".")..last = "255";
          _wifiBroadcast = s.join(".");
        }
        _logger.i(_wifiBroadcast);
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  String getMyIp() => _ip;

  Future<String?> getIp(String uid) async {
    if (uid == _authRepo.currentUserUid.asString()) {
      return _ip;
    }
    try {
      if (_address[uid] != null) {
        return _address[uid];
      }
      final ip = (await _localNetworkConnectionDao.get(uid.asUid()))?.ip;
      if (ip != null) {
        _address[uid] = ip;
        return ip;
      } else {
        sendBroadCast(to: uid.asUid());
      }
    } catch (e) {
      _logger.e(e);
    }
    return null;
  }
}
