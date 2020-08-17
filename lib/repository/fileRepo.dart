import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/uploadFileServices.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class FileRepo {
  var fileDao = GetIt.I.get<FileDao>();
  final uploader = FlutterUploader();
  var avatarDao = GetIt.I.get<AvatarDao>();

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().fileConnection.host,
      port: ServicesDiscoveryRepo().fileConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  Future<File> getFileRequest(String uuid, String filename) {
    throw Error();
  }

  saveFileInfo(String fileId, String fileName, String filePath) async {
    FileInfo fileInfo = FileInfo(
        id: fileId,
        path: filePath,
        fileName: fileName,
        downloadTaskId: "1",
        downloadTaskStatus: "1");
    fileDao.insertFileInfo(fileInfo);
    print("file save");
  }

  uploadFile(File file) async {
    UploadFileServices().uploadFile(file.path).then((value) {
      FileInfo fileInfo = FileInfo(
          path: file.path,
          fileName: file.path.substring(file.path.lastIndexOf("/")));
      fileDao.insertFileInfo(fileInfo);
      print("file save");
    }).catchError((error) {});
  }

  Future<File> getFile(String uuid, String filename) async {
    FileInfo fileInfo;
    fileDao.getFile(uuid).then((files) => fileInfo = files.elementAt(0));
    File file = new File(fileInfo.path);
    var isExist = await file.exists();
    if (isExist) {
      return file;
    } else {
      return await getFileRequest(uuid, filename);
    }
  }
}
