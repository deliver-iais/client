import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;

import 'package:fixnum/fixnum.dart';

import 'package:get_it/get_it.dart';

class FileRepo {
  var _fileDao = GetIt.I.get<FileDao>();
  var _fileService = GetIt.I.get<FileService>();

  Future<void> cloneFileInLocalDirectory(
      File file, String uploadKey, String name) async {
    final localFile = await _fileService.localFile(uploadKey, name);
    localFile.writeAsBytesSync(file.readAsBytesSync());

    await _saveFileInfo(uploadKey, localFile, name, "real");
    await _saveFileInfo(uploadKey, localFile, name, "large");
  }

  Future<FileProto.File> uploadClonedFile(String uploadKey, String name,{Function sendActivity}) async {
    final clonedFilePath = await _fileService.localFilePath(uploadKey, name);

    var value =
        await _fileService.uploadFile(clonedFilePath, uploadKey: uploadKey,sendActivity: sendActivity);

    var json = jsonDecode(value.toString());
    var uploadedFile = FileProto.File()
      ..uuid = json["uuid"]
      ..size = Int64.parseInt(json["size"])
      ..type = json["type"]
      ..name = json["name"]
      ..width = json["width"] ?? 0
      ..height = json["height"] ?? 0
      ..duration = json["duration"] ?? 0;

    print(uploadedFile.toString());

    await _updateFileInfoWithRealUuid(uploadKey, uploadedFile.uuid);

    return uploadedFile;
  }

  Future<bool> isExist(String uuid, String filename,
      {ThumbnailSize thumbnailSize}) async {
    FileInfo fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      File file = new File(fileInfo.path);
      return await file.exists();
    }
    return false;
  }

  Future<File> getFileIfExist(String uuid, String filename,
      {ThumbnailSize thumbnailSize}) async {
    FileInfo fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      File file = new File(fileInfo.path);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  //todo delete
  Future<List<File>> getStickers()async {
    List<File> stickers = new List();
    stickers.add(await getFile('eda821dc-878d-4020-ab3b-51f346ff4689', "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker4382935534051180548.jpg"));
    stickers.add(await getFile("ecf4fbb6-e975-459f-8958-d79de57829eb", "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker5222062023281853666.jpg"));
    stickers.add(await getFile("bb04b15c-cfaf-4dc3-9282-33866b1b842c", "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker558697332465276485.png"));
    return stickers;

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
    await _saveFileInfo(uuid, downloadedFile, filename,
        thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
    return downloadedFile;
  }

  Future<FileInfo> _saveFileInfo(
      String fileId, File file, String name, String compressionSize) async {
    FileInfo fileInfo = FileInfo(
      uuid: fileId,
      name: name,
      path: file.path,
      compressionSize: compressionSize,
    );
    await _fileDao.upsert(fileInfo);
    return fileInfo;
  }

  Future<void> _updateFileInfoWithRealUuid(
      String uploadKey, String uuid) async {
    var real = await _getFileInfoInDB("real", uploadKey);
    var large = await _getFileInfoInDB("large", uploadKey);
    await _fileDao.deleteFileInfo(real);
    await _fileDao.deleteFileInfo(large);
    await _fileDao.upsert(real.copyWith(uuid: uuid));
    await _fileDao.upsert(large.copyWith(uuid: uuid));
  }

  Future<FileInfo> _getFileInfoInDB(String size, String uuid) async {
    return await _fileDao.getFileInfo(uuid, enumToString(size));
  }

  void initUploadProgress(String uploadId) {
    _fileService.initUpoadProgrss(uploadId);
  }
}
