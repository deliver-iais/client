import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/local_network_file.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ServerLessFileService {
  RawDatagramSocket? _fileReceiverSocket;
  RawDatagramSocket? _fileSenderSocket;
  final _logger = GetIt.I.get<Logger>();

  final Map<String, Map<int, List<Int64>>> _files = {};

  bool _isListenedAlready = false;

  Future<void> startFileServer({
    bool retry = true,
  }) async {
    try {
      if (_fileReceiverSocket == null || !_isListenedAlready) {
        _fileReceiverSocket?.close();
        _fileReceiverSocket = await RawDatagramSocket.bind(
          GetIt.I.get<ServerLessService>().getMyIp(),
          FILE_SERVER_PORT,
        );
        _fileReceiverSocket?.listen((event) {
          try {
            _isListenedAlready = true;
            final data = _fileReceiverSocket?.receive()?.data;
            if (data != null) {
              final localNetworkFile = LocalNetworkFile.fromBuffer(data);
              _saveFile(localNetworkFile);
            }
            _isListenedAlready = false;
          } catch (e) {
            _isListenedAlready = false;
            _logger.e(e);
          }
        });
      } else {
        _logger.i("can not start  file server already listen on ............");
      }
    } catch (e) {
      _logger
        ..i("start file server")
        ..e(e.toString());
      _isListenedAlready = false;
      _fileReceiverSocket?.close();
      if (retry) {
        unawaited(
          startFileServer(
            retry: false,
          ),
        );
      }
      _logger.e(e);
    }
  }

  void dispose() {
    _fileReceiverSocket?.close();
    _fileSenderSocket?.close();
    _files.clear();
  }

  Future<bool> sendFile({
    required String filePath,
    required String receiverIp,
    required String uuid,
    required String name,
    bool isResend = false,
  }) async {
    try {
      _fileSenderSocket?.close();
      _fileSenderSocket = await RawDatagramSocket.bind(
        GetIt.I.get<ServerLessService>().getBroadcastIp(),
        FILE_SERVER_PORT,
      );
      _fileSenderSocket?.broadcastEnabled = true;

      final bytes = File(filePath).readAsBytesSync();

      final length = bytes.length;
      if (length > FILE_MAX_BUFFER_SIZE) {
        var i = 0;
        while (i <= length) {
          final m = LocalNetworkFile(
            uuid: uuid,
            name: name,
            isResend: isResend,
            index: Int64(((i / FILE_MAX_BUFFER_SIZE).floor()) + 1),
            finish: i + FILE_MAX_BUFFER_SIZE >= length,
            data: bytes
                .sublist(i, min(length, i + FILE_MAX_BUFFER_SIZE))
                .map((e) => Int64(e))
                .toList(),
          );

          _fileSenderSocket?.send(
            m.writeToBuffer(),
            InternetAddress(receiverIp),
            FILE_SERVER_PORT,
          );
          i = i + FILE_MAX_BUFFER_SIZE;
          GetIt.I
              .get<FileService>()
              .updateFileProgressbar(min((i / length), 1), uuid);

          await Future.delayed(const Duration(milliseconds: 300));
        }
      } else {
        _fileSenderSocket?.send(
          LocalNetworkFile(
            uuid: uuid,
            name: name,
            isResend: isResend,
            index: Int64(1),
            finish: true,
            data: bytes.map((e) => Int64(e)).toList(),
          ).writeToBuffer(),
          InternetAddress(receiverIp),
          FILE_SERVER_PORT,
        );
      }
      _fileSenderSocket?.close();
      return true;
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  Future<void> _saveFile(LocalNetworkFile localNetworkFile) async {
    try {
      if (_files[localNetworkFile.uuid] == null) {
        _files[localNetworkFile.uuid] = {};
      }
      _files[localNetworkFile.uuid]![localNetworkFile.index.toInt()] =
          localNetworkFile.data;

      if (localNetworkFile.finish) {
        final sortedKeys = _files[localNetworkFile.uuid]!.keys.toList()..sort();
        final bytes = <int>[];
        for (final element in sortedKeys) {
          bytes.addAll(
            (_files[localNetworkFile.uuid]![element])!.map((e) => e.toInt()),
          );
        }
        _logger.i(
          "${localNetworkFile.uuid}........\t............${bytes.length}",
        );
        unawaited(
          GetIt.I.get<FileRepo>().saveLocalNetworkFile(
                uuid: localNetworkFile.uuid,
                filename: localNetworkFile.name,
                data: bytes,
              ),
        );
        _files.remove(localNetworkFile.uuid);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> resendFile({
    required String ip,
    required String uuid,
    required String name,
  }) async {
    final filePath = await GetIt.I.get<FileRepo>().getFileIfExist(uuid);
    if (filePath != null) {
      unawaited(
        sendFile(
          filePath: filePath,
          receiverIp: ip,
          uuid: uuid,
          name: name,
          isResend: true,
        ),
      );
    }
  }

  Future<bool> checkIfFileExit({
    required String uuid,
  }) async =>
      (await GetIt.I.get<FileRepo>().getFileIfExist(uuid)) != null;
}
