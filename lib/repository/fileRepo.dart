// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io' as io;
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;

import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class FileRepo {
  final _logger = GetIt.I.get<Logger>();
  final _fileDao = GetIt.I.get<FileDao>();
  final _fileService = GetIt.I.get<FileService>();
  Map<String, BehaviorSubject<int?>> uploadFileStatusCode = {};

  Future<void> cloneFileInLocalDirectory(
      io.File file, String uploadKey, String name) async {
    _saveFileInfo(uploadKey, file.path, name, "real");
  }

  Future<file_pb.File?> uploadClonedFile(String uploadKey, String name,
      {Function? sendActivity}) async {
    final clonedFilePath = await _fileDao.get(uploadKey, "real");
    if (uploadFileStatusCode[uploadKey] == null) {
      final d = BehaviorSubject<int>.seeded(0);
      uploadFileStatusCode[uploadKey] = d;
    }
    Response? value;
    try {
      value = await _fileService.uploadFile(clonedFilePath!.path, name,
          uploadKey: uploadKey, sendActivity: sendActivity);
    } on DioError catch (e) {
      if (e.response != null) {
        uploadFileStatusCode[uploadKey]!.add(e.response!.statusCode);
      }
      _logger.e(e);
    }
    if (value != null) {
      final json = jsonDecode(value.toString());
      uploadFileStatusCode[uploadKey]!.add(value.statusCode);
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
          ..hash = json["hash"] ?? "";
        _logger.v(uploadedFile);

        await _updateFileInfoWithRealUuid(uploadKey, uploadedFile.uuid);
        return uploadedFile;
      } catch (e) {
        _logger.e(e);
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> isExist(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    final fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      if (isWeb) return fileInfo.path.isNotEmpty;
      final file = io.File(fileInfo.path);
      return file.exists();
    }
    return false;
  }

  Future<void> saveDownloadedFile(String url, String filename) =>
      _fileService.saveDownloadedFile(url, filename);

  Future<String?> getFileIfExist(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    final fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      if (isWeb) {
        return Uri.parse(fileInfo.path).toString();
      } else {
        final file = io.File(fileInfo.path);
        if (await file.exists()) {
          return file.path;
        }
      }
    }
    return null;
  }

  Future<String?> getFile(String uuid, String filename,
      {ThumbnailSize? thumbnailSize, bool intiProgressBar = true}) async {
    final path =
        await getFileIfExist(uuid, filename, thumbnailSize: thumbnailSize);
    if (path != null) {
      return isWeb ? Uri.parse(path).toString() : path;
    }
    final downloadedFileUri =
        await _fileService.getFile(uuid, filename, size: thumbnailSize);
    if (downloadedFileUri != null) {
      if (isWeb) {
        final res = await http.get(Uri.parse(downloadedFileUri));
        final bytes = Uri.dataFromBytes(res.bodyBytes.toList()).toString();
        await _saveFileInfo(uuid, bytes, filename,
            thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
        if (intiProgressBar) {
          if (_fileService.filesProgressBarStatus[uuid] != null) {
            _fileService.filesProgressBarStatus[uuid]!.add(DOWNLOAD_COMPLETE);
          }
        }

        return downloadedFileUri;
      }

      await _saveFileInfo(uuid, downloadedFileUri, filename,
          thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
      if (intiProgressBar) {
        if (_fileService.filesProgressBarStatus[uuid] != null) {
          _fileService.filesProgressBarStatus[uuid]!.add(DOWNLOAD_COMPLETE);
        }
      }

      return downloadedFileUri;
    } else {
      return null;
    }
  }

  Future<FileInfo> _saveFileInfo(
      String fileId, String filePath, String name, String sizeType) async {
    final fileInfo = FileInfo(
      uuid: fileId,
      name: name,
      path: filePath,
      sizeType: sizeType,
    );
    await _fileDao.save(fileInfo);
    return fileInfo;
  }

  Future<void> _updateFileInfoWithRealUuid(
      String uploadKey, String uuid) async {
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

  void initUploadProgress(String uploadId) {
    _fileService.initProgressBar(uploadId);
  }

  void saveFileInDownloadDir(String uuid, String name, String dir) async {
    final path = await getFileIfExist(uuid, name);
    _fileService.saveFileInDownloadFolder(path!, name, dir);
  }
}
