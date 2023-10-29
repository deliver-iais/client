import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver_public_protocol/pub/v1/models/local_network_file.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ServerLessFileService {
  RawDatagramSocket? _fileReceiverSocket;
  RawDatagramSocket? _fileSenderSocket;
  final _logger = GetIt.I.get<Logger>();
  var _closed = false;

  final Map<String, List<Int64>> _files = {};

  var _lastRequestedFileUuid = "";

  Future<void> startFileServer(
    String ip, {
    required String lastRequestedFileUuid,
  }) async {
    try {
      _lastRequestedFileUuid = lastRequestedFileUuid;
      if (_fileReceiverSocket == null || _closed) {
        _fileReceiverSocket = await RawDatagramSocket.bind(ip, FILE_SERVER_PORT)
          ..broadcastEnabled = true;
        _fileReceiverSocket?.listen((event) {
          try {
            final data = _fileReceiverSocket?.receive()?.data;
            if (data != null) {
              final localNetworkFile = LocalNetworkFile.fromBuffer(data);
              _logger.i(localNetworkFile.uuid);
              _saveFile(localNetworkFile);
            }
          } catch (e) {
            _logger.e(e);
          }
        });
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void disposeFileServer(String fileUuid) {
    if (fileUuid == _lastRequestedFileUuid) {
      _fileReceiverSocket?.close();
      _closed = true;
    }
  }

  List<int> toIntList(Uint8List source) {
    return List.from(source);
  }

  Future<bool> sendFile({
    required String filePath,
    required String receiverIp,
    required String uuid,
    required String name,
  }) async {
    try {
      _fileSenderSocket ??= await RawDatagramSocket.bind(receiverIp, FILE_SERVER_PORT);
      final bytes = File(filePath).readAsBytesSync();

      final length = bytes.length;
      _logger.i(length);
      if (length > FILE_MAX_BUFFER_SIZE) {
        var i = 0;
        while (i <= length) {
          final m = LocalNetworkFile(
            uuid: uuid,
            name: name,
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

          await Future.delayed(const Duration(milliseconds: 100));
        }
      } else {
        _fileSenderSocket?.send(
          LocalNetworkFile(
            uuid: uuid,
            name: name,
            finish: true,
            data: bytes.map((e) => Int64(e)).toList(),
          ).writeToBuffer(),
          InternetAddress(receiverIp),
          FILE_SERVER_PORT,
        );
      }


      return true;
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  Future<void> _saveFile(LocalNetworkFile localNetworkFile) async {
    try {
      if (_files[localNetworkFile.uuid] == null) {
        _files[localNetworkFile.uuid] = [];
      }
      _files[localNetworkFile.uuid]!.addAll(localNetworkFile.data);
      if (localNetworkFile.finish) {
        _logger.i("save..................");
        unawaited(
          GetIt.I.get<FileRepo>().saveLocalNetworkFile(
                uuid: localNetworkFile.uuid,
                filename: localNetworkFile.name,
                data: _files[localNetworkFile.uuid]!
                    .map((e) => e.toInt())
                    .toList(),
              ),
        );
        _files.remove(localNetworkFile.uuid);
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
