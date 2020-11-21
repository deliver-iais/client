import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:fimber/fimber.dart';

import 'package:get_it/get_it.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

class FileRepo {
  var _fileDao = GetIt.I.get<FileDao>();
  var _fileService = GetIt.I.get<FileService>();

  Future<FileInfo> saveFileInfo(
      String fileId, File file, String name,String type, String compressionSize) async {
    FileInfo fileInfo = FileInfo(
      uuid: fileId,
      path: file.path,
      type: type,
      name: name,
      compressionSize: compressionSize,
    );
    await _fileDao.upsert(fileInfo);
    return fileInfo;
  }


  Future<FileInfo> uploadFile(File file,{String uploadKey}) async {
    var value = await _fileService.uploadFile(file.path,uploadKey:uploadKey);
    print(value.toString());
    FileInfo savedFile = await saveFileInfo(
        jsonDecode(value.toString())["uuid"],
        file,jsonDecode(value.toString())["uuid"],
        jsonDecode(value.toString())["name"],
        "real");
    return savedFile;
  }

  Future<bool> isExist(String uuid, String filename,
      {ThumbnailSize thumbnailSize}) async {
    FileInfo fileInfo = await _getFileInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      File file = new File(fileInfo.path);
      return await file.exists();
    }
    return false;
  }

  Future<File> getFileIfExist(String uuid, String filename,
      {ThumbnailSize thumbnailSize}) async {
    FileInfo fileInfo = await _getFileInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      File file = new File(fileInfo.path);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  Future<File> getFile(String uuid, String filename,
      {ThumbnailSize thumbnailSize}) async {
    File file =
        await getFileIfExist(uuid, filename, thumbnailSize: thumbnailSize);
    if (file != null) {
      return file;
    }

    var downloadedFile =
        await _fileService.getFile(uuid, filename, size: thumbnailSize);
    await saveFileInfo(uuid, downloadedFile, filename,"",
        thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
    return downloadedFile;
  }

  Future<FileInfo> _getFileInDB(String size, String uuid) async {
    return await _fileDao.getFileInfo(uuid, enumToString(size));
  }
}
