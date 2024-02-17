import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:deliver/cache/file_cache.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/serverless/serverless_constance.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_size_getter/image_size_getter.dart';
import 'package:logger/logger.dart';

class ServerLessFileService {
  final _logger = GetIt.I.get<Logger>();
  final _fileService = GetIt.I.get<FileService>();
  final _fileCache = GetIt.I.get<FileInfoCache>();

  Future<file_pb.File?> buildMessageFile({
    required Uid uid,
    required String name,
    required String path,
    required String uploadKey,
    bool isVoice = false,
  }) async {
    var audioWaveform0 = file_pb.AudioWaveform();
    if (await GetIt.I.get<ServerLessFileService>().sendFile(
          name: name,
          filePath: path,
          uuid: uploadKey,
          receiverIp: GetIt.I.get<ServerLessService>().getIp(uid.asString())!,
        )) {
      if (isVoice) {
        audioWaveform0 = file_pb.AudioWaveform(data: [0]);
      }
      var duration = 0.0;
      var tempDimension = Size.zero;
      try {
        final tempType = detectFileMimeByFileModel(model.File(path, name));
        if (isImageFileType(tempType)) {
          tempDimension = getImageDimension(path);
          if (tempDimension == Size.zero) {
            tempDimension =
                const Size(DEFAULT_FILE_DIMENSION, DEFAULT_FILE_DIMENSION);
          }
        } else if (isVideoFileType(tempType)) {
          final info = await getVideoInfo(path);
          if (info != null) {
            tempDimension = Size(info.width!, info.height!);
            duration = info.duration! / 1000;
          }
          audioWaveform0 = file_pb.AudioWaveform(
            data: [tempDimension.width, tempDimension.height].map((e) => e),
          );
        }
      } catch (e) {
        _logger.e("Error in fetching fake file dimensions", error: e);
      }
      final size = await io.File(path).length();
      await _updateFileInfoWithRealUuid(uploadKey, uploadKey, name);
      return file_pb.File(
        uuid: uploadKey,
        name: getFileName(name),
        audioWaveform: audioWaveform0,
        width: tempDimension.width,
        height: tempDimension.height,
        duration: duration,
        isLocal: true,
        size: Int64(size),
        hash: "hash",
        type: detectFileMimeByFileModel(model.File(path, name)),
        sign: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }
    return null;
  }

  Future<void> _updateFileInfoWithRealUuid(
    String uploadKey,
    String uuid,
    String name,
  ) async {
    final real = await _fileCache.getFilePath("real", uploadKey);

    if (real != null) {
      await _fileCache.updateFileInfoUuid(uploadKey, uuid, name, "real", real);
    }
    final medium = await _fileCache.getFilePath("medium", uploadKey);
    if (medium != null) {
      await _fileCache.updateFileInfoUuid(
        uploadKey,
        uuid,
        name,
        "medium",
        medium,
      );
    }
  }

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
        onProgress: (i, j) =>
            GetIt.I.get<FileService>().updateFileProgressbar((i / j), uuid),
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
      return (await http.Response.fromStream(await request.send()))
              .statusCode ==
          HttpStatus.ok;
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  Future<void> handleSaveFile(HttpRequest request) async {
    try {
      final fileSize = int.parse(request.headers.value(FILE_SIZE)!);
      var multiPartFileSize = 0;
      final data = Uint8List(fileSize + 500);
      await request.forEach((element) async {
        data.setRange(
          multiPartFileSize,
          multiPartFileSize + element.length,
          element,
        );
        multiPartFileSize = multiPartFileSize + element.length;
      });

      final diff = multiPartFileSize - fileSize;

      await _saveFile(
        data.sublist(diff - 78, multiPartFileSize - 78),
        uuid: request.headers.value(FILE_UUID)!,
        name: String.fromCharCodes(
          request.headers.value(FILE_NAME)!.split(',').map((e) => int.parse(e)),
        ),
      );

      request.response.statusCode = HttpStatus.ok;
    } catch (e) {
      print(e);
      request.response.statusCode = HttpStatus.internalServerError;
    }
    return request.response.close();
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

  Future<void> uploadLocalNetworkFile(List<file_pb.File> files) async {
    for (final file in files) {
      try {
        final path = await _fileCache.getFilePath('real', file.uuid);
        if (path != null) {
          await _fileService.uploadLocalNetworkFile(
            filePath: path,
            uuid: file.uuid,
            filename: file.name,
            isVoice: false,
          );
        }
      } catch (e) {
        _logger.e(e);
      }
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
