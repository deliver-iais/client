import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:deliver_flutter/box/dao/file_dao.dart';
import 'package:deliver_flutter/box/file_info.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileRepo {
  var _fileDao = GetIt.I.get<FileDao>();
  final _fileService = GetIt.I.get<FileService>();

  Future<void> cloneFileInLocalDirectory(
      File file, String uploadKey, String name) async {
    if (false) {
      ReceivePort receivePort = ReceivePort();
      Map myMap = Map<String, dynamic>();
      myMap['file'] = file.path;
      myMap['sendPort'] = receivePort.sendPort;
      myMap['uploadKey'] = uploadKey;
      myMap['name'] = name;
      var isolate;
      try {
        isolate = await FlutterIsolate.spawn(decodeIsolate, myMap);
        debug("isolate spawn finished successfulllyyyyyyyyyyyy");
      } catch (e) {
        debug("isolate errrrrrrrrrrrrrrrorrrrrrrrr" + e.toString());
      }
      Map allLocalFiles = await receivePort.first as Map;
      isolate.kill();
      await _saveFileInfo(uploadKey, File(allLocalFiles['real']), name, "real");
      await _saveFileInfo(
          uploadKey, File(allLocalFiles['large']), name, "large");
      await _saveFileInfo(
          uploadKey, File(allLocalFiles['medium']), name, "medium");
      await _saveFileInfo(
          uploadKey, File(allLocalFiles['small']), name, "small");
    } else {
      await _saveFileInfo(uploadKey, file, name, "real");
    }
  }

  Future<FileProto.File> uploadClonedFile(String uploadKey, String name,
      {Function sendActivity}) async {
    final clonedFilePath = await _fileDao.get(uploadKey, "real");
    var value = await _fileService.uploadFile(clonedFilePath.path,
        uploadKey: uploadKey, sendActivity: sendActivity);

    var json = jsonDecode(value.toString());
    var uploadedFile = FileProto.File()
      ..uuid = json["uuid"]
      ..size = Int64.parseInt(json["size"])
      ..type = json["type"]
      ..name = json["name"]
      ..width = json["width"] ?? 0
      ..height = json["height"] ?? 0
      ..duration = json["duration"] ?? 0;

    debug(uploadedFile.toString());

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

  Future<File> getFile(String uuid, String filename,
      {ThumbnailSize thumbnailSize}) async {
    File file =
        await getFileIfExist(uuid, filename, thumbnailSize: thumbnailSize);
    if (file != null) {
      return file;
    }
    if (thumbnailSize == ThumbnailSize.large) {
      var downloadedFile =
          await _fileService.getFile(uuid, filename, size: ThumbnailSize.large);

      var mediumDownloadedFile = await _fileService.getFile(uuid, filename,
          size: ThumbnailSize.medium);

      await _saveFileInfo(uuid, downloadedFile, filename,
          thumbnailSize != null ? enumToString(ThumbnailSize.large) : 'real');

      await _saveFileInfo(uuid, mediumDownloadedFile, filename,
          thumbnailSize != null ? enumToString(ThumbnailSize.medium) : 'real');
      return downloadedFile;
    }
    var downloadedFile =
        await _fileService.getFile(uuid, filename, size: thumbnailSize);
    await _saveFileInfo(uuid, downloadedFile, filename,
        thumbnailSize != null ? enumToString(thumbnailSize) : 'real');
    return downloadedFile;
  }

  Future<File> downloadFile(String uuid, String fileName,
      {ThumbnailSize thumbnailSize}) async {
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
    var large = await _getFileInfoInDB("large", uploadKey);
    var medium = await _getFileInfoInDB("medium", uploadKey);
    var small = await _getFileInfoInDB("small", uploadKey);

    await _fileDao.remove(real);
    if (large != null) {
      await _fileDao.remove(large);
    }
    if (medium != null) {
      await _fileDao.remove(medium);
    }
    if (small != null) {
      await _fileDao.remove(small);
    }

    await _fileDao.save(real.copyWith(uuid: uuid));

    if (large != null) {
      await _fileDao.save(large.copyWith(uuid: uuid));
    }
    if (medium != null) {
      await _fileDao.save(medium.copyWith(uuid: uuid));
    }
    if (small != null) {
      await _fileDao.save(small.copyWith(uuid: uuid));
    }
  }

  Future<FileInfo> _getFileInfoInDB(String size, String uuid) async {
    return await _fileDao.get(uuid, enumToString(size));
  }

  void initUploadProgress(String uploadId) {
    _fileService.initUpoadProgrss(uploadId);
  }
}

void decodeIsolate(Map<dynamic, dynamic> param) async {
  Image largeThumbnail;
  Image mediumThumbnail;
  Image smallThumbnail;
  Directory directory;
  Map fileMap = Map<dynamic, dynamic>();

  directory = await getApplicationDocumentsDirectory();
  if (!await Directory('${directory.path}/Deliver').exists())
    await Directory('${directory.path}//Deliver').create(recursive: true);

  final realLocalFile = File(
      '${directory.path + "/Deliver"}/${param['uploadKey']}.${param['name']}');

  final largeLocalFile = File(
      '${directory.path + "/Deliver"}/${param['uploadKey'] + "-large"}.${param['name']}');
  ;

  final mediumLocalFile = File(
      '${directory.path + "/Deliver"}/${param['uploadKey'] + "-medium"}.${param['name']}');

  final smallLocalFile = File(
      '${directory.path + "/Deliver"}/${param['uploadKey'] + "-small"}.${param['name']}');
  Image image = decodeImage(File(param['file']).readAsBytesSync());
  if (image.width > image.height) {
    largeThumbnail = copyResize(image, width: 500);
    mediumThumbnail = copyResize(image, width: 300);
    smallThumbnail = copyResize(image, width: 64);
  } else {
    largeThumbnail = copyResize(image, height: 500);
    mediumThumbnail = copyResize(image, height: 300);
    smallThumbnail = copyResize(image, height: 64);
  }

  realLocalFile.writeAsBytesSync(File(param['file']).readAsBytesSync());
  largeLocalFile.writeAsBytesSync(encodeJpg(largeThumbnail));
  mediumLocalFile.writeAsBytesSync(encodeJpg(mediumThumbnail));
  smallLocalFile.writeAsBytesSync(encodeJpg(smallThumbnail));
  fileMap['real'] = realLocalFile.path;
  fileMap['large'] = largeLocalFile.path;
  fileMap['medium'] = mediumLocalFile.path;
  fileMap['small'] = smallLocalFile.path;

  SendPort sendport = param['sendPort'];

  sendport.send(fileMap);
}
