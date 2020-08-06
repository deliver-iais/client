import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class UploadFile {


  httpUploadFile(File file) async {
    Map map = new Map<String, String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    map["Authorization"] = accessToken;

    var uri = Uri.parse("https://172.16.111.189:30010/upload");
    var request = new MultipartRequest("POST", uri);
    var multipartFile = await MultipartFile.fromPath("package", file.path);
    request.headers.addAll(map);

    request.persistentConnection = true;
    request.files.add(multipartFile);
    StreamedResponse response = await request.send().then((v) {
      print("resulttttttt" + v.toString());
    }).catchError((e) {
      print("error" + e.toString());
    });
    response.stream.transform(utf8.decoder).listen((value) {
      print("kdfjjfd");
    });
  }


  final uploader = FlutterUploader();
  var servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  Future<String> uploadFile(File file) async {
    // todo : use upload progress to show progress
    uploader.progress.listen((progress) {
      print(progress.progress.toString() + "%");
      if (progress.status == UploadTaskStatus.canceled) {
        //todo
        print("canceled");
      }
      if (progress.status == UploadTaskStatus.failed) {
        print("failed");
      }
      if (progress.status == UploadTaskStatus.complete) {
        print("compelete");
        // todo
      }
    });
    Map map = new Map<String, String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    map["Authorization"] = accessToken;
    print("accessToken=" + accessToken);
    final taskId = await uploader
        .enqueue(
      headers: map,
      url: "https://" + servicesDiscoveryRepo.FileConnection.host +
          ":" + servicesDiscoveryRepo.FileConnection.port.toString() +
          "/upload",
      //required: url to upload to
      files: [
        FileItem(
            filename: "",
            savedDir: file.path,
            fieldname: "file")
      ],
      method: UploadMethod.POST,
      showNotification: false,
    );
        return taskId;
    }

  cancelUpload(String taskId) {
    uploader.cancel(taskId: taskId);
  }

  cancelAllUpload() {
    uploader.cancelAll();
  }
}
