import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class FileRepo {
  var fileDao = GetIt.I.get<FileDao>();
  var avatarDao = GetIt.I.get<AvatarDao>();
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().FileConnection.host,
      port: ServicesDiscoveryRepo().FileConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  String generateAvatarFile(String fileId, String fileName) {
    return "/samll/$fileId/$fileName";
  }
  Future<File> getFileRequest(String uuid){
    // todo get file from server
  }

  Future<File> getFile(String uuid) async  {
    FileInfo fileInfo;
    fileDao.getFile(uuid).then((files) => fileInfo = files.elementAt(0));
    File file = new File(fileInfo.path);
    var isExist = await file.exists();
    if (isExist) {
      return file;
    } else {
      return await getFileRequest(uuid);
    }
  }
}
