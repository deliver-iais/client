import 'dart:io';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:get_it/get_it.dart';

class UploadFile {
  final uploader = FlutterUploader();
  var servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  Future<String> uploadFile(File file) async {
    // todo : use upload progress to show progress

    uploader.progress.listen((progress) {
      print(progress.progress.toString() + "%");
      if (progress.status == UploadTaskStatus.canceled) {
        //todo
      }
      if (progress.status == UploadTaskStatus.failed) {
        // todo
      }
      if (progress.status == UploadTaskStatus.complete) {
        // todo
      }
    });
    final taskId = await uploader
        .enqueue(
      url: servicesDiscoveryRepo.FileConnection.host +
          ":" +
          servicesDiscoveryRepo.FileConnection.port.toString(),
      //required: url to upload to
      files: [
        FileItem(
            filename: file.path.substring(file.path.lastIndexOf("/")),
            savedDir: file.path,
            fieldname: "file")
      ],
      method: UploadMethod.POST,
      showNotification: false,
    )
        .then(((value) {
      print("upload file is down ");
      print("fileinfo:"+value.toString());
    })).catchError((error) {
      print(" upload file is fail ");
    });
    return taskId;
  }

  cancelUpload(String taskId) {
    uploader.cancel(taskId: taskId);
  }

  cancelAllUpload() {
    uploader.cancelAll();
  }
}
