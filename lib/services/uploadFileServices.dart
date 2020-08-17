import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

class UploadFileServices {
  var fileRepo = GetIt.I.get<FileRepo>();
  var accountRepo = GetIt.I.get<AccountRepo>();
  var servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  uploadFileList(List<String> filesPath)  {
    for(String filePath in filesPath){
      uploadFile(filePath);
    }
  }

  uploadFile(String filePath) async{
    Dio dio = new Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.headers["Authorization"] = await accountRepo.getAccessToken();
      options.onSendProgress = (int i, int j) {
        Fimber.d("upload " + ((i / j) * 100).toString() + "%");
      };
      return options; //continue
    }, onResponse: (Response response) async {
      return response;
    }, onError: (DioError e) async {
      return e; //continue
    }));

      var formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath),
      });

      var response = await dio.post(
          "http://${servicesDiscoveryRepo.fileConnection.host}:${servicesDiscoveryRepo.fileConnection.port}/upload",
          data: formData);
      Fimber.d(response.statusCode.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.toString());
        fileRepo.saveFileInfo(result["uuid"], result["name"], filePath);
      }
    }


}
