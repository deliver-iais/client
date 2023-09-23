// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:deliver/cache/file_cache.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:universal_html/html.dart' as html;

class FileRepo {
  final _logger = GetIt.I.get<Logger>();
  final _fileService = GetIt.I.get<FileService>();
  final _fileCache = GetIt.I.get<FileInfoCache>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();

  final _i18N = GetIt.I.get<I18N>();

  Map<String, String> localUploadedFilePath = {};

  Future<void> saveInFileInfo(
    io.File file,
    String uploadKey,
    String name,
  ) {
    return _fileCache.saveFileInfo(uploadKey, file.path, name, "real");
  }

  Future<file_pb.File?> uploadClonedFile(
    String uploadKey,
    String name, {
    required List<String> packetIds,
    void Function(int)? sendActivity,
    bool isVoice = false,
  }) async {
    final clonedFilePath = await _fileCache.getFilePath(
      "real",
      uploadKey,
      convertToDataByteInWeb: true,
    );

    Response? value;
    try {
      value = await _fileService.uploadFile(
        clonedFilePath!,
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
          duration: AnimationSettings.actualSuperUltraSlow,
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
          duration: AnimationSettings.actualSuperUltraSlow,
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

        localUploadedFilePath[uploadedFile.uuid] = clonedFilePath!;
        await _updateFileInfoWithRealUuid(uploadKey, uploadedFile.uuid, name);
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

  Future<String?> getFilePathFromFileProto(file_pb.File file) {
    return getFile(
      file.uuid,
      file.name,
    );
  }

  Future<bool> isExist(
    String uuid,
    String filename, {
    ThumbnailSize? thumbnailSize,
  }) async {
    final fileInfo = await _fileService.getFile(
      (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize),
      uuid,
    );
    if (fileInfo != null) {
      if (isWeb) {
        return fileInfo.isNotEmpty;
      }
      final file = io.File(fileInfo);
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
    final filePath = await _fileCache.getFilePath(
      (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize),
      uuid,
    );
    if (filePath != null) {
      if (isWeb) {
        return filePath;
      } else {
        final file = io.File(filePath);
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
    String? directUrl,
    ThumbnailSize? thumbnailSize,
    bool intiProgressbar = true,
    bool showAlertOnError = false,
  }) async {
    final path =
        await getFileIfExist(uuid, filename, thumbnailSize: thumbnailSize);
    if (path != null) {
      return path;
    }
    final downloadedFileUri = await _fileService.getFile(
      uuid,
      filename,
      size: thumbnailSize,
      directUrl: directUrl,
      initProgressbar: intiProgressbar,
      showAlertOnError: showAlertOnError,
    );
    if (downloadedFileUri != null) {
      final filePath = await _fileCache.saveFileInfo(
        uuid,
        downloadedFileUri,
        filename,
        thumbnailSize != null ? enumToString(thumbnailSize) : 'real',
      );
      if (intiProgressbar) {
        _fileService.updateFileStatus(uuid, FileStatus.COMPLETED);
      }

      return filePath;
    } else {
      return null;
    }
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

  void saveDownloadedFileInWeb(String uuid, String name) {
    getFileIfExist(uuid, name).then((url) {
      if (url != null) {
        _fileService.saveDownloadedFile(url, name);
      }
    });
  }

  void saveTableAdImage(Uint8List res, String title) {
    Future.delayed(const Duration(milliseconds: 250)).then((value) {
      FilePicker.platform
          .saveFile(
        lockParentWindow: true,
        type: FileType.image,
        dialogTitle: title,
      )
          .then((outputFile) {
        if (outputFile != null) {
          _fileService.saveCaptureFile(res, outputFile);
        }
      });
    });
  }

  void saveFileInDownloadDir(
    String uuid,
    String name,
    String dir,
  ) {
    getFileIfExist(uuid, name).then(
      (path) => isDesktopNative
          ? _fileService.saveFileInDesktopDownloadFolder(name, path!)
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

  Future<void> openFile(
    String filePath, {
    bool preferShowInFolder = false,
  }) async {
    if (isWeb) {
      // isWeb Checked
      // ignore: unsafe_html
      html.window.open(filePath, "_");
    } else {
      if (preferShowInFolder && isLinuxNative) {
        onShowInFolder(filePath);
      } else {
        OpenFilex.open(filePath).ignore();
      }
    }
  }

  void copyFileToPasteboard(
    String path,
  ) {
    Pasteboard.writeFiles([path]);
  }
}
