import 'dart:io';

import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class FileRepo {
  var _fileDao = GetIt.I.get<FileDao>();
  var _fileService = GetIt.I.get<FileService>();

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().fileConnection.host,
      port: ServicesDiscoveryRepo().fileConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  Future<File> getFileThumbnailRequest(
      String size, String uuid, String filename) async {
    var dio = Dio();
    print(size);
    return (await dio.get<File>("172.16.111.189:30010/$size/$uuid/$filename"))
        .data;
  }

  saveFileInfo(String fileId, String fileName, String path, String size) async {
    FileInfo fileInfo =
        FileInfo(uuid: fileId, path: path, fileName: fileName, size: size);
    _fileDao.upsert(fileInfo);
  }

  uploadFile(File file) async {
    _fileService.uploadFile(file.path).then((value) {
      saveFileInfo(value.uuid, file.path.substring(file.path.lastIndexOf("/")),
          file.path, "real");
    }).catchError((error) {});
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
