import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';

import 'package:get_it/get_it.dart';

class FileRepo {
  var _fileDao = GetIt.I.get<FileDao>();
  var _fileService = GetIt.I.get<FileService>();

  Future<FileInfo> saveFileInfo(
      String fileId, String path, String fileName, String size) async {
    FileInfo fileInfo =
        FileInfo(uuid: fileId, path: path, fileName: fileName, size: size);
    await _fileDao.upsert(fileInfo);
    return fileInfo;
  }

  uploadFileList(List<String> filesPath) {
    for (String filePath in filesPath) {
      uploadFile(File(filePath));
    }
  }

  Future<FileInfo> uploadFile(File file) async {
    var value = await _fileService.uploadFile(file.path);
    return saveFileInfo(jsonDecode(value.toString())["uuid"],
        jsonDecode(value.toString())["name"], file.path, "real");
  }

  Future<File> getFile(String uuid, String filename) async {
    FileInfo fileInfo = await getFileInDB("real", uuid);
    if (fileInfo != null) {
      File file = new File(fileInfo.path);
      var isExist = await file.exists();
      if (isExist) {
        return file;
      } else {
        var downloadedFile = await _fileService.getFile(uuid, filename);
        saveFileInfo(uuid, downloadedFile.path, filename, "real");
        return downloadedFile;
      }
    } else {
      var downloadedFile = await _fileService.getFile(uuid, filename);
      saveFileInfo(uuid, downloadedFile.path, filename, "real");
      return downloadedFile;
    }
  }

  Future<File> getFileThumbnail(
      ThumbnailSize size, String uuid, String filename) async {
    FileInfo fileInfo = await getFileInDB(enumToString(size), uuid);
    if (fileInfo != null) {
      File file = new File(fileInfo.path);
      var isExist = await file.exists();
      if (isExist) {
        return file;
      } else {
        var downloadedFile =
            await _fileService.getFileThumbnail(uuid, filename, size);
        saveFileInfo(uuid, downloadedFile.path, filename, enumToString(size));
        return downloadedFile;
      }
    } else {
      var downloadedFile =
          await _fileService.getFileThumbnail(uuid, filename, size);
      saveFileInfo(uuid, downloadedFile.path, filename, enumToString(size));
      return downloadedFile;
    }
  }

  Future<FileInfo> getFileInDB(String size, String uuid) async {
    var infoList = await _fileDao.getFileInfo(uuid, enumToString(size));
    if (infoList.isNotEmpty)
      return infoList.elementAt(0);
    else
      return null;
  }


}
