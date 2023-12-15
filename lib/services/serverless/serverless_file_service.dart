import 'dart:async';
import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ServerLessFileService {
  final _logger = GetIt.I.get<Logger>();

  Future<bool> sendFile({
    required String filePath,
    required String receiverIp,
    required String uuid,
    required String name,
    bool isResend = false,
  }) async {
    try {
      final length = await File(filePath).length();
      final multi = await http.MultipartFile.fromPath(
        'file',
        filePath,
      );
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$receiverIp:$SERVER_PORT'),
      )
        ..files.add(multi)
        ..headers[TYPE] = FILE
        ..headers[FILE_SIZE] = length.toString()
        ..headers[FILE_UUID] = uuid
        ..headers[FILE_NAME] = name;

      await (await request.send()).stream.forEach((message) {
        print("%%%%%%%%%%" + (message.length / length).toString());
      });
      return true;
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  Future<void> handleFileUpload(HttpRequest request) async {
    try {
      final fileSize = int.parse(request.headers.value(FILE_SIZE)!);
      final data = <int>[];
      await request.forEach((element) async {
        data.addAll(element);
      });
      final diff = data.length - fileSize;
      await _saveFile(
        data.sublist(diff - 78, data.length - 78),
        uuid: request.headers.value(FILE_UUID)!,
        name: request.headers.value(FILE_NAME)!,
      );
      request.response.statusCode = HttpStatus.ok;
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
    }
    await request.response.close();
  }

  Future<void> _saveFile(
    List<int> bytes, {
    required String uuid,
    required String name,
  }) async {
    try {
      await GetIt.I.get<FileRepo>().saveLocalNetworkFile(
            uuid: uuid,
            filename: name,
            data: bytes,
          );
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
