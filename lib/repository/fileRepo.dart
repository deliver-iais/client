// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io' as io;

import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:dio/dio.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';

class FileRepo {
  final _logger = GetIt.I.get<Logger>();
  final _fileDao = GetIt.I.get<FileDao>();
  final _fileService = GetIt.I.get<FileService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();

  final _i18N = GetIt.I.get<I18N>();

  Map<String, String> localUploadedFilePath = {};

  Future<void> saveInFileInfo(
    io.File file,
    String uploadKey,
    String name,
  ) {
    return _saveFileInfo(uploadKey, file.path, name, "real");
  }

  Future<file_pb.File?> uploadClonedFile(
    String uploadKey,
    String name, {
    required List<String> packetIds,
    void Function(int)? sendActivity,
    bool isVoice = false,
  }) async {
    final clonedFilePath = await _fileDao.get(uploadKey, "real");

    Response? value;
    try {
      value = await _fileService.uploadFile(
        clonedFilePath!.path,
        name,
        uploadKey: uploadKey,
        sendActivity: sendActivity,
        isVoice: isVoice,
      );
      await _analyticsService.sendLogEvent(
        "successFileUpload",
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 400 && packetIds.isNotEmpty) {
        ToastDisplay.showToast(
          toastText: e.response!.data,
          maxWidth: 500.0,
          duration: SUPER_ULTRA_SLOW_ANIMATION_DURATION,
        );
        for (final packetId in packetIds) {
          GetIt.I.get<MessageRepo>().deletePendingMessage(packetId);
        }
        cancelUploadFile(uploadKey);
        await _analyticsService.sendLogEvent(
          "unSuccessFileUpload",
          parameters: {
            "errorCode": e.response?.statusCode,
            "error": e.response?.data
          },
        );
      } else if (e.response == null && e.type != DioErrorType.cancel) {
        ToastDisplay.showToast(
          toastText: _i18N.get("connection_error"),
          maxWidth: 500.0,
          duration: SUPER_ULTRA_SLOW_ANIMATION_DURATION,
        );
        for (final packetId in packetIds) {
          GetIt.I.get<MessageRepo>().deletePendingMessage(packetId);
        }
        cancelUploadFile(uploadKey);
        await _analyticsService.sendLogEvent(
          "failedFileUpload",
        );
      } else {
        await _analyticsService.sendLogEvent(
          "unknownFileUpload",
          parameters: {
            "errorCode": e.response?.statusCode,
            "error": e.response?.data
          },
        );
      }
      _logger.e(e);
    }
    if (value != null) {
      final json = jsonDecode(value.toString()) as Map;
      _fileService.updateFileStatus(uploadKey, FileStatus.COMPLETED);

      try {
        var uploadedFile = file_pb.File();
        uploadedFile = file_pb.File()
          ..uuid = json["uuid"]
          ..size = Int64.parseInt(json["size"])
          ..type = json["type"]
          ..name = json["name"]
          ..width = json["width"] ?? 0
          ..height = json["height"] ?? 0
          ..duration = json["duration"] ?? 0
          ..blurHash = json["blurHash"] ?? ""
          ..hash = json["hash"] ?? ""
          ..sign = json["sign"] ?? "";
        if (json["audioWaveform"] != null) {
          final audioWaveform = json["audioWaveform"] as Map;
          if (audioWaveform.isNotEmpty) {
            uploadedFile.audioWaveform = file_pb.AudioWaveform(
              bits: audioWaveform["bits"] ?? 0,
              channels: audioWaveform["channels"] ?? 0,
              data: audioWaveform["data"] != null
                  ? List<int>.from(audioWaveform["data"])
                  : [],
              length: audioWaveform["length"] ?? 0,
              sampleRate: audioWaveform["sampleRate"] ?? 0,
              samplesPerPixel: audioWaveform["samplesPerPixel"] ?? 0,
              version: audioWaveform["version"] ?? 0,
            );
          }
        }
        _logger.v(uploadedFile);

        localUploadedFilePath[uploadedFile.uuid] = clonedFilePath!.path;
        await _updateFileInfoWithRealUuid(uploadKey, uploadedFile.uuid);
        _fileService.updateFileStatus(uploadedFile.uuid, FileStatus.COMPLETED);
        return uploadedFile;
      } catch (e) {
        _fileService.updateFileStatus(uploadKey, FileStatus.CANCELED);
        _logger.e(e);
        return null;
      }
    } else {
      _fileService.updateFileStatus(uploadKey, FileStatus.CANCELED);
      _fileService.filesProgressBarStatus
          .add(_fileService.filesProgressBarStatus.value..[uploadKey] = 0.0);
      return null;
    }
  }

  Future<bool> isExist(
    String uuid,
    String filename, {
    ThumbnailSize? thumbnailSize,
  }) async {
    final fileInfo = await _getFileInfoInDB(
      (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize),
      uuid,
    );
    if (fileInfo != null) {
      if (isWeb) return fileInfo.path.isNotEmpty;
      final file = io.File(fileInfo.path);
      return file.existsSync();
    }
    return false;
  }

  void saveDownloadedFile(String url, String filename) =>
      _fileService.saveDownloadedFile(url, filename);

  bool fileExitInCache(String uuid) =>
      localUploadedFilePath[uuid] != null &&
      localUploadedFilePath[uuid]!.isNotEmpty &&
      (isWeb || io.File(localUploadedFilePath[uuid]!).existsSync());

  Future<String?> getFileIfExist(
    String uuid,
    String filename, {
    ThumbnailSize? thumbnailSize,
  }) async {
    if (thumbnailSize == null && fileExitInCache(uuid)) {
      return localUploadedFilePath[uuid];
    }
    final fileInfo = await _getFileInfoInDB(
      (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize),
      uuid,
    );
    if (fileInfo != null) {
      if (isWeb) {
        return Uri.parse(fileInfo.path).toString();
      } else {
        final file = io.File(fileInfo.path);
        if (file.existsSync()) {
          return file.path;
        }
      }
    }
    return null;
  }

  Future<String?> getFile(
    String uuid,
    String filename, {
    ThumbnailSize? thumbnailSize,
    bool intiProgressbar = true,
    bool showAlertOnError = false,
  }) async {
    final path =
        await getFileIfExist(uuid, filename, thumbnailSize: thumbnailSize);
    if (path != null) {
      return isWeb ? Uri.parse(path).toString() : path;
    }
    final downloadedFileUri = await _fileService.getFile(
      uuid,
      filename,
      size: thumbnailSize,
      initProgressbar: intiProgressbar,
      showAlertOnError: showAlertOnError,
    );
    if (downloadedFileUri != null) {
      if (isWeb) {
        final res = await http.get(Uri.parse(downloadedFileUri));
        final bytes = Uri.dataFromBytes(res.bodyBytes.toList()).toString();
        await _saveFileInfo(
          uuid,
          bytes,
          filename,
          thumbnailSize != null ? enumToString(thumbnailSize) : 'real',
        );
        if (intiProgressbar) {
          _fileService.updateFileStatus(uuid, FileStatus.COMPLETED);
        }
        return downloadedFileUri;
      }

      await _saveFileInfo(
        uuid,
        downloadedFileUri,
        filename,
        thumbnailSize != null ? enumToString(thumbnailSize) : 'real',
      );
      if (intiProgressbar) {
        _fileService.updateFileStatus(uuid, FileStatus.COMPLETED);
      }

      return downloadedFileUri;
    } else {
      return null;
    }
  }

  Future<FileInfo> _saveFileInfo(
    String fileId,
    String filePath,
    String name,
    String sizeType,
  ) {
    final fileInfo = FileInfo(
      uuid: fileId,
      name: name,
      path: filePath,
      sizeType: sizeType,
    );
    return _fileDao.save(fileInfo).then((value) => fileInfo);
  }

  Future<void> _updateFileInfoWithRealUuid(
    String uploadKey,
    String uuid,
  ) async {
    final real = await _getFileInfoInDB("real", uploadKey);
    final medium = await _getFileInfoInDB("medium", uploadKey);

    await _fileDao.remove(real!);
    if (medium != null) {
      await _fileDao.remove(medium);
    }

    await _fileDao.save(real.copyWith(uuid: uuid));
    if (medium != null) {
      await _fileDao.save(medium.copyWith(uuid: uuid));
    }
  }

  Future<FileInfo?> _getFileInfoInDB(String size, String uuid) async =>
      _fileDao.get(uuid, enumToString(size));

  void saveDownloadedFileInWeb(String uuid, String name, String type) {
    getFileIfExist(uuid, name).then((url) {
      if (url != null) {
        _fileService.saveDownloadedFile(url, name);
      }
    });
  }

  void saveFileInDownloadDir(
    String uuid,
    String name,
    String dir,
  ) {
    getFileIfExist(uuid, name).then(
      (path) => isDesktop
          ? _fileService.saveFileInDesktopDownloadFolder(uuid, name, path!)
          : _fileService.saveFileInMobileDownloadFolder(path!, name, dir),
    );
  }

  void cancelUploadFile(String uuid) {
    _fileService.cancelUploadOrDownloadFile(uuid);
  }

  void saveFileToSpecifiedAddress(
    String uuid,
    String name,
    String address, {
    bool convertToJpg = true,
  }) {
    getFileIfExist(uuid, name).then(
      (path) => _fileService.saveFileToSpecifiedAddress(
        path!,
        address,
        convertToJpg: convertToJpg,
      ),
    );
  }

  void copyFileToPasteboard(
    String path,
  ) {
    Pasteboard.writeFiles([path]);
  }
}
