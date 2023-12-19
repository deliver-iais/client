import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
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
  }) async {
    try {
      final length = await File(filePath).length();
      final request = MultipartRequest(
        'POST',
        Uri.parse('http://$receiverIp:$SERVER_PORT'),
        onProgress: (i, j) {
          GetIt.I.get<FileService>().updateFileProgressbar((i / j), uuid);
        },
      )
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            filePath,
          ),
        )
        ..headers[TYPE] = FILE
        ..headers[FILE_SIZE] = length.toString()
        ..headers[FILE_UUID] = uuid
        ..headers[FILE_NAME] = name.codeUnits.join(',');
      final response = await http.Response.fromStream(await request.send());
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  Future<void> handleSaveFile(HttpRequest request) async {
    try {
      final fileSize = int.parse(request.headers.value(FILE_SIZE)!);
      final data = <int>[];
      await request.forEach((element) async {
        data.addAll(element);
      });
      final diff = data.length - fileSize;
      final name = String.fromCharCodes(
        request.headers.value(FILE_NAME)!.split(',').map((e) => int.parse(e)),
      );
      await _saveFile(
        data.sublist(diff - 78, data.length - 78),
        uuid: request.headers.value(FILE_UUID)!,
        name: name,
      );
      data.clear();
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
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    super.method,
    super.url, {
    required this.onProgress,
  });

  final void Function(int bytes, int totalBytes) onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();

    final total = contentLength;
    var bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress.call(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
