// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as file_pb;

import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class FileRepo {
  final _logger = GetIt.I.get<Logger>();
  final _fileDao = GetIt.I.get<FileDao>();
  final _fileService = GetIt.I.get<FileService>();

  Future<void> cloneFileInLocalDirectory(
      File file, String uploadKey, String name) async {
    await _saveFileInfo(uploadKey, file, name, "real");
  }

  Future<file_pb.File> uploadClonedFile(String uploadKey, String name,
      {Function? sendActivity}) async {
    final clonedFilePath = await _fileDao.get(uploadKey, "real");
    var value = await _fileService.uploadFile(clonedFilePath!.path!,
        uploadKey: uploadKey, sendActivity: sendActivity);

    var json = jsonDecode(value.toString());
    var uploadedFile = file_pb.File()
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
      File file = File(fileInfo.path!);
      return await file.exists();
    }
    return false;
  }

  Future<File?> getFileIfExist(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    FileInfo? fileInfo = await _getFileInfoInDB(
        (thumbnailSize == null) ? 'real' : enumToString(thumbnailSize), uuid);
    if (fileInfo != null) {
      File file = File(fileInfo.path!);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  Future<File?> getFile(String uuid, String filename,
      {ThumbnailSize? thumbnailSize}) async {
    File? file =
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

  Future<File> downloadFile(String uuid, String fileName,
      {ThumbnailSize? thumbnailSize}) async {
    var downloadedFile =
        await _fileService.getFile(uuid, fileName, size: thumbnailSize);
    await _saveFileInfo(uuid, downloadedFile, fileName,
        thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
    return downloadedFile;
  }

  Future<FileInfo> _saveFileInfo(
      String fileId, File file, String name, String sizeType) async {
    FileInfo fileInfo = FileInfo(
      uuid: fileId,
      name: name,
      path: file.path,
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
    var file = await getFileIfExist(uuid, name);
    _fileService.saveFileInDownloadFolder(file!, name, dir);
  }
}

// void decodeIsolate(Map<dynamic, dynamic> param) async {
//   Image largeThumbnail;
//   Image mediumThumbnail;
//   Image smallThumbnail;
//   Directory directory;
//   Map fileMap = Map<dynamic, dynamic>();
//
//   directory = await getApplicationDocumentsDirectory();
//   if (!await Directory('${directory.path}/Deliver').exists())
//     await Directory('${directory.path}//Deliver').create(recursive: true);
//
//   final realLocalFile = File(
//       '${directory.path + "/Deliver"}/${param['uploadKey']}.${param['name']}');
//
//   final largeLocalFile = File(
//       '${directory.path + "/Deliver"}/${param['uploadKey'] + "-large"}.${param['name']}');
//
//
//   final mediumLocalFile = File(
//       '${directory.path + "/Deliver"}/${param['uploadKey'] + "-medium"}.${param['name']}');
//
//   final smallLocalFile = File(
//       '${directory.path + "/Deliver"}/${param['uploadKey'] + "-small"}.${param['name']}');
//   Image image = decodeImage(File(param['file']).readAsBytesSync());
//   if (image.width > image.height) {
//     largeThumbnail = copyResize(image, width: 500);
//     mediumThumbnail = copyResize(image, width: 300);
//     smallThumbnail = copyResize(image, width: 64);
//   } else {
//     largeThumbnail = copyResize(image, height: 500);
//     mediumThumbnail = copyResize(image, height: 300);
//     smallThumbnail = copyResize(image, height: 64);
//   }
//
//   realLocalFile.writeAsBytesSync(File(param['file']).readAsBytesSync());
//   largeLocalFile.writeAsBytesSync(encodeJpg(largeThumbnail));
//   mediumLocalFile.writeAsBytesSync(encodeJpg(mediumThumbnail));
//   smallLocalFile.writeAsBytesSync(encodeJpg(smallThumbnail));
//   fileMap['real'] = realLocalFile.path;
//   fileMap['large'] = largeLocalFile.path;
//   fileMap['medium'] = mediumLocalFile.path;
//   fileMap['small'] = smallLocalFile.path;
//
//   SendPort sendport = param['sendPort'];
//
//   sendport.send(fileMap);
// }
