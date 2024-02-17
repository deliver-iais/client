import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:deliver/box/dao/local_network-connection_dao.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_file_service.dart';
import 'package:deliver/services/serverless/serverless_message_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/register.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/server_less_packet.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ServerLessService {
  final Dio _dio = Dio();
  final _networkInfo = NetworkInfo();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();
  final address = <String, Address>{}.obs;
  final superNodes = <String>[].obs;
  final _localNetworkConnectionDao = GetIt.I.get<LocalNetworkConnectionDao>();
  final _serverLessFileService = GetIt.I.get<ServerLessFileService>();
  final _notificationForegroundService =
      GetIt.I.get<NotificationForegroundService>();
  var _ip = "";

  HttpServer? _httpServer;

  RawDatagramSocket? _upSocket;

  var _wifiBroadcast = "255.255.255.255";

  void start() {
    GetIt.I.get<ServerLessMessageService>().reset();
    _start();
  }

  void _start() {
    address.clear();
    _startServices();
    _startForeground();
  }

  void _startForeground() {
    if (address.isNotEmpty && Platform.isAndroid) {
      _startForegroundService();
    }
  }

  bool inLocalNetwork(Uid uid) =>
      uid.asString().contains(LOCAL_MUC_ID) ||
      address.containsKey(uid.asString());

  Future<void> _startForegroundService() async {
    try {
      await _notificationForegroundService.stopForegroundTask();
      final foregroundStatus = await _notificationForegroundService
          .localNetworkForegroundServiceStart();
      if (foregroundStatus) {
        _notificationForegroundService.getReceivePort?.listen((message) {
          if (message == ForeGroundConstant.STOP_LOCAL_NETWORK) {
            _notificationForegroundService.stopForegroundTask();
          }
        });
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  bool superNodeExit() => superNodes.isNotEmpty;

  String? getSuperNodeIp() {
    try {
      if (superNodes.isEmpty) {
        return null;
      }
      final uid = superNodes
          .where((element) => element != _authRepo.currentUserUid.asString())
          .first;
      return address[uid]?.url;
    } catch (e) {
      return null;
    }
  }

  Uid? getSuperNode() {
    try {
      if (superNodes.isEmpty) {
        return null;
      }
      return superNodes
          .where((element) => element != _authRepo.currentUserUid.asString())
          .first
          .asUid();
    } catch (e) {
      return null;
    }
  }

  Future<void> restart() async {
    await _dispose();
    _start();
  }

  Future<void> _dispose() async {
    if (Platform.isAndroid) {
      await _notificationForegroundService.stopForegroundTask();
    }
    await _httpServer?.close(force: true);
    _upSocket?.close();
    GetIt.I.get<ServerLessMessageService>().reset();
  }

  String getBroadcastIp() => _wifiBroadcast;

  Future<void> _clearConnections() async {
    address.clear();
    await _localNetworkConnectionDao.deleteAll();
  }

  Future<void> _startServices() async {
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
          ..multicastLoopback = true
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

  Future<void> _shareOthersLocation() async {
    try {
      _upSocket?.send(
        ServerLessPacket(
          shareLocalNetworkInfo: ShareLocalNetworkInfo(
            from: _authRepo.currentUserUid,
            address: _getAddressList(),
          ),
        ).writeToBuffer(),
        InternetAddress(_wifiBroadcast),
        UDP_PORT,
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendMyLocalNetworkInfo({
    bool retry = true,
  }) async {
    try {
      if (settings.isSuperNode.value) {
        superNodes.add(_authRepo.currentUserUid.asString());
      } else {
        superNodes.remove(_authRepo.currentUserUid.asString());
      }
      _upSocket?.send(
        ServerLessPacket(
          myLocalNetworkInfo: MyLocalNetworkInfo(
            from: _authRepo.currentUserUid,
            address: Address(
              url: _ip,
              uid: _authRepo.currentUserUid,
              isSuperNode: settings.isSuperNode.value,
              backupLocalMessage: settings.backupLocalNetworkMessages.value,
            ),
          ),
        ).writeToBuffer(),
        InternetAddress(_wifiBroadcast),
        UDP_PORT,
      );
    } catch (e) {
      if (retry) {
        await Future.delayed(const Duration(milliseconds: 800));
        await sendMyLocalNetworkInfo(retry: false);
      }
      _logger.e(e);
    }
  }

  List<Address> _getAddressList() => address.values.toList()
    ..add(
      Address(
        uid: _authRepo.currentUserUid,
        url: _ip,
        backupLocalMessage: settings.backupLocalNetworkMessages.value,
        isSuperNode: settings.isSuperNode.value,
      ),
    );

  Future<Response?> sendRequest(ServerLessPacket serverLessPacket, String url,
      {bool retry = true}) async {
    try {
      return _dio.post(
        "http://$url:$SERVER_PORT",
        data: serverLessPacket.writeToBuffer(),
        options: Options(
          headers: {
            IP: _ip,
          },
          contentType: ContentType.binary.mimeType,
        ),
      );
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return sendRequest(serverLessPacket, url, retry: false);
      }
    }
    return null;
  }

  Future<void> _startHttpService() async {
    try {
      await _httpServer?.close(force: true);
      _httpServer = await HttpServer.bind(_ip, SERVER_PORT);
      _logger.i('Listening on $_ip:${_httpServer?.port}');
      if (_httpServer != null) {
        _httpServer?.listen((request) {
          try {
            final type = request.headers.value(TYPE) ?? "";
            if (type == FILE) {
              unawaited(_serverLessFileService.handleSaveFile(request));
            } else {
              unawaited(_processIncomingReq(request));
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
    unawaited(sendMyLocalNetworkInfo());
  }

  Future<void> _processIncomingReq(HttpRequest request) async {
    try {
      final serverLessPacket = ServerLessPacket.fromBuffer(await request.first);
      if (serverLessPacket.hasMyLocalNetworkInfo()) {
      } else if (serverLessPacket.hasShareLocalNetworkInfo()) {
        await _processShareLocalNetworkInfo(
          serverLessPacket.shareLocalNetworkInfo,
        );
      } else {
        await GetIt.I
            .get<ServerLessMessageService>()
            .processIncomingPacket(serverLessPacket);
        request.response.statusCode = HttpStatus.ok;
      }

      await request.response.close();
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;

      _logger.e(e);
      await request.response.close();
    }
  }

  Future<void> _processIncomingMyLocalNetworkInfo(
    MyLocalNetworkInfo myLocalNetworkInfo,
  ) async {
    try {
      unawaited(_saveIp(myLocalNetworkInfo.address));
    } catch (e) {
      _logger.e(e);
    }
    unawaited(_shareOthersLocation());
  }

  Future<void> _processShareLocalNetworkInfo(
    ShareLocalNetworkInfo shareLocalNetworkInfo,
  ) async {
    try {
      for (final address in shareLocalNetworkInfo.address) {
        unawaited(_saveIp(address));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _handleBroadCastMessage(Uint8List data) async {
    try {
      final packet = ServerLessPacket.fromBuffer(data);
      if (packet.hasShareLocalNetworkInfo() &&
          !packet.shareLocalNetworkInfo.from
              .isSameEntity(_authRepo.currentUserUid.asString())) {
        await _processShareLocalNetworkInfo(packet.shareLocalNetworkInfo);
      } else if (packet.hasMyLocalNetworkInfo() &&
          !packet.shareLocalNetworkInfo.from
              .isSameEntity(_authRepo.currentUserUid.asString())) {
        await _processIncomingMyLocalNetworkInfo(packet.myLocalNetworkInfo);
      }
      _startForeground();
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _reset() async {
    await Future.delayed(const Duration(milliseconds: 700));
    await _httpServer?.close(force: true);
    await _startHttpService();
  }

  Future<bool> _getMyLocalIp() async {
    var needToClearConnections = false;
    var newIp = "";
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );

    if (Platform.isAndroid) {
      final wifiIp = await NetworkInfo().getWifiIP();
      if (wifiIp == null) {
        newIp = interfaces
            .where((element) =>
                element.addresses.first.address.split(".").last == "1")
            .first
            .addresses
            .first
            .address;
      } else {
        newIp = wifiIp;
      }
    } else if (Platform.isWindows) {
      try {
        newIp = interfaces
            .where((e) => e.name.contains("Wi"))
            .first
            .addresses
            .first
            .address;
      } catch (e) {
        newIp = interfaces
            .where((e) => e.name.contains("Ethernet"))
            .first
            .addresses
            .first
            .address;
      }
    }
    if (_ip != newIp) {
      needToClearConnections = true;
    }
    _ip = newIp;
    _logger.i("///////////// " "\t$_ip");

    return needToClearConnections;
  }

  Future<void> _saveIp(
    Address addresses,
  ) async {
    if (!addresses.uid.isSameEntity(_authRepo.currentUserUid.asString())) {
      try {
        _logger.i(
            "----->>> New info address ${addresses.url}----------------------------");
        address[addresses.uid.asString()] = addresses;
        if (addresses.isSuperNode) {
          superNodes.add(addresses.uid.asString());
        } else {
          superNodes.remove(addresses.uid.asString());
        }
        unawaited(
          _localNetworkConnectionDao.save(
            LocalNetworkConnections(
              uid: addresses.uid,
              ip: addresses.url,
              backupLocalMessages: addresses.backupLocalMessage,
              lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  Future<void> _initWifiBroadcast() async {
    try {
      if (Platform.isAndroid) {
        final wifi = await _networkInfo.getWifiBroadcast();
        if (wifi != null) {
          _wifiBroadcast = wifi;
        } else {
          _wifiBroadcast = (_ip.split(".")..last = "255").join(".");
        }
      } else if (Platform.isWindows) {
        _wifiBroadcast = (_ip.split(".")..last = "255").join(".");
      }
      _logger.i(_wifiBroadcast);
    } catch (e) {
      _logger.e(e);
    }
  }

  String getMyIp() => _ip;

  Future<String?> getIpAsync(String uid) async {
    if (uid.contains(LOCAL_MUC_ID)) {
      return null;
    }
    if (uid == _authRepo.currentUserUid.asString()) {
      return _ip;
    }
    try {
      if (address[uid] != null) {
        return address[uid]?.url;
      } else {
        unawaited(sendMyLocalNetworkInfo());
      }
    } catch (e) {
      _logger.e(e);
    }
    return null;
  }

  String? getIp(String uid) => address[uid]?.url;

  void removeIp(String uid) {
    address.remove(uid);
    _localNetworkConnectionDao.delete(uid.asUid());
  }
}
