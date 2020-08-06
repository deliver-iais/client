import 'dart:io';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber_base.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:get_it/get_it.dart';
//import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UploadFile {

  Future<String> accessToken() async {
    return "abbas";
  }

  httpUploadFile(File file) async {
    Map headers = new Map<String, String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    headers["Authorization"] = accessToken;
    Dio dio = new Dio();
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(RequestOptions options) async {
          options.headers["Authorization"] = await this.accessToken();
          // Do something before request is sent
          return options; //continue
          // If you want to resolve the request with some custom data，
          // you can return a `Response` object or return `dio.resolve(data)`.
          // If you want to reject the request with a error message,
          // you can return a `DioError` object or return `dio.reject(errMsg)`
        },
        onResponse:(Response response) async {
          // Do something with response data
          return response; // continue
        },
        onError: (DioError e) async {
          // Do something with response error
          return  e;//continue
        }
    ));

    var formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
    });

    var response = await dio.post("http://172.16.111.189:30010/upload", data: formData, options: Options(headers: headers));

    Fimber.d(response.statusCode.toString());
//    var uri = Uri.parse("http://172.16.111.189:30010/upload");
//    var request = new MultipartRequest("POST", uri);
//    var multipartFile = await MultipartFile.fromPath("file", file.path);

//    request.headers.map((key, value){
//      return MapEntry("Authorization",accessToken);
//    });


//    request.persistentConnection = true;
//    request.files.add(multipartFile);
//     var res =await request.send();

//    if (res.statusCode == 200) print('Uploaded!');
//    else{
//      print(res.statusCode.toString());
//    }
//    response.stream.transform(utf8.decoder).listen((value) {
//      print("kdfjjfd");
//    });
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
      headers:map,
      url:"http://"+servicesDiscoveryRepo.FileConnection.host+
          ":"+servicesDiscoveryRepo.FileConnection.port.toString()+"/upload",
      //required: url to upload to
      files: [
        FileItem(
          filename: "",
            savedDir: file.path,
            )
      ],
      method: UploadMethod.POST,
      showNotification: false,
    ).catchError((e){
      print("1111111111111111"+e.toString());
    }).then((value) {
      print("result="+value.toString());
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
