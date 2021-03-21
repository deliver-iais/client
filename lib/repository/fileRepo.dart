import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;

import 'package:fixnum/fixnum.dart';
import 'package:image/image.dart';
import 'package:get_it/get_it.dart';

class FileRepo {
  var _fileDao = GetIt.I.get<FileDao>();
  var _fileService = GetIt.I.get<FileService>();

  Future<void> cloneFileInLocalDirectory(
      File file, String uploadKey, String name) async {
    var receivePort = ReceivePort();
    final realLocalFile = await _fileService.localFile(uploadKey, name);
    final largeLocalFile = await _fileService.localFile(uploadKey+"-large", name);
    final mediumLocalFile = await _fileService.localFile(uploadKey+"-medium", name);
    final smallLocalFile = await _fileService.localFile(uploadKey+"-small", name);
    await Isolate.spawn(
        decodeIsolate,DecodeParam(file, receivePort.sendPort,uploadKey,name));
    ThumnailsKinds allImages = await receivePort.first as ThumnailsKinds;
    realLocalFile.writeAsBytesSync(file.readAsBytesSync());
    largeLocalFile.writeAsBytesSync(encodeJpg(allImages.largeThumnail));
    mediumLocalFile.writeAsBytesSync(encodeJpg(allImages.mediumThumnail));
    smallLocalFile.writeAsBytesSync(encodeJpg(allImages.smallThumnail));

    await _saveFileInfo(uploadKey, realLocalFile, name, "real");
    await _saveFileInfo(uploadKey, largeLocalFile, name, "large");
    await _saveFileInfo(uploadKey, mediumLocalFile, name, "medium");
    await _saveFileInfo(uploadKey, smallLocalFile, name, "small");

  }
  void decodeIsolate(DecodeParam param) async{
    Image largeThumbnail;
    Image mediumThumbnail;
    Image smallThumbnail;

    Image image = decodeImage(param.file.readAsBytesSync());
    if(image.width>image.height){
      largeThumbnail = copyResize(image, width: 500);
      mediumThumbnail = copyResize(image, width: 300);
      smallThumbnail = copyResize(image, width: 64);
    } else {
      largeThumbnail = copyResize(image, height: 500);
      mediumThumbnail = copyResize(image, height: 300);
      smallThumbnail = copyResize(image, height: 64);
    }
    ThumnailsKinds thumnailsKinds = ThumnailsKinds(largeThumbnail, mediumThumbnail, smallThumbnail);
     param.sendPort.send(thumnailsKinds);

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

  Future<File> downloadFile(String uuid , String fileName,{ThumbnailSize thumbnailSize}) async{
    var downloadedFile =
    await _fileService.getFile(uuid, fileName, size: thumbnailSize);
    await _saveFileInfo(uuid, downloadedFile, fileName,
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
    var medium = await _getFileInfoInDB("medium", uploadKey);
    var small = await _getFileInfoInDB("small", uploadKey);
    await _fileDao.deleteFileInfo(real);
    await _fileDao.deleteFileInfo(medium);
    await _fileDao.deleteFileInfo(large);
    await _fileDao.deleteFileInfo(small);
    await _fileDao.upsert(real.copyWith(uuid: uuid));
    await _fileDao.upsert(large.copyWith(uuid: uuid));
    await _fileDao.upsert(medium.copyWith(uuid: uuid));
    await _fileDao.upsert(small.copyWith(uuid: uuid));
  }

  Future<FileInfo> _getFileInfoInDB(String size, String uuid) async {
    return await _fileDao.getFileInfo(uuid, enumToString(size));
  }

  void initUploadProgress(String uploadId) {
    _fileService.initUpoadProgrss(uploadId);
  }
}

class DecodeParam {
  final File file;
  final SendPort sendPort;
  String uploadKey;
  String name;

  DecodeParam(this.file, this.sendPort,this.uploadKey,this.name);
}

class ThumnailsKinds {
  Image largeThumnail;
  Image mediumThumnail;
  Image smallThumnail;

  ThumnailsKinds(this.largeThumnail, this.mediumThumnail, this.smallThumnail);

}
