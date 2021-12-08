// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:universal_html/html.dart' as html;

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:universal_html/html.dart';

class FileRepo {
  final _logger = GetIt.I.get<Logger>();
  final _fileDao = GetIt.I.get<FileDao>();
  final _fileService = GetIt.I.get<FileService>();

  //var sessionResource = StorageEntry('token', type: StorageType.localStorage);

  Future<void> cloneFileInLocalDirectory(
      io.File file, String uploadKey, String name) async {
    await _saveFileInfo(uploadKey, file.path, name, "real");
  }

  Future<file_pb.File> uploadClonedFile(String uploadKey, String name,
      {Function? sendActivity}) async {
    final clonedFilePath = await _fileDao.get(uploadKey, "real");
    var value = await _fileService.uploadFile(clonedFilePath!.path!, name,
        uploadKey: uploadKey, sendActivity: sendActivity!);

    var json = jsonDecode(value.toString());
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
  }

  Future<bool> isExist(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    FileInfo? fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      if (kIsWeb) return fileInfo.path != null;
      io.File file = io.File(fileInfo.path!);
      return await file.exists();
    }
    return false;
  }

  saveDownloadedFile(String url, String filename) =>
      _fileService.saveDownloadedFile(url, filename);

  Future<String?> getFileIfExist(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    FileInfo? fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      if (kIsWeb) {
        return Uri.parse(fileInfo.path!).toString();
      } else {
        io.File file = io.File(fileInfo.path!);
        if (await file.exists()) {
          return file.path;
        }
      }
    }
    return null;
  }

  Future<String?> getFile(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    String? path =
        await getFileIfExist(uuid, filename, thumbnailSize: thumbnailSize);
    if (path != null) {
      return kIsWeb ? Uri.parse(path).toString() : path;
    }
    var downloadedFileUri =
        await _fileService.getFile(uuid, filename, size: thumbnailSize);
    if (downloadedFileUri != null) {
      if (kIsWeb) {
        var res = await http.get(Uri.parse(downloadedFileUri));
        String bytes = Uri.dataFromBytes(res.bodyBytes.toList()).toString();
        await _saveFileInfo(uuid, bytes, filename,
            thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
        return downloadedFileUri;
      }

      await _saveFileInfo(uuid, downloadedFileUri, filename,
          thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
      return downloadedFileUri;
    } else {
      return null;
    }
  }

  Future<FileInfo> _saveFileInfo(
      String fileId, String filePath, String name, String sizeType) async {
    FileInfo fileInfo = FileInfo(
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
    var real = await _getFileInfoInDB("real", uploadKey);
    var medium = await _getFileInfoInDB("medium", uploadKey);

    await _fileDao.remove(real!);
    if (medium != null) {
      await _fileDao.remove(medium);
    }

    await _fileDao.save(real.copyWith(uuid: uuid));

    if (medium != null) {
      await _fileDao.save(medium.copyWith(uuid: uuid));
    }
  }

  Future<FileInfo?> _getFileInfoInDB(String size, String uuid) async {
    return await _fileDao.get(uuid, enumToString(size));
  }

  void initUploadProgress(String uploadId) {
    _fileService.initUpoadProgrss(uploadId);
  }

  void saveFileInDownloadDir(String uuid, String name, String dir) async {
    String? path = await getFileIfExist(uuid, name);
    _fileService.saveFileInDownloadFolder(path!, name, dir);
  }
}
