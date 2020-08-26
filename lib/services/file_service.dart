import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

enum ThumbnailSize { small, medium, large }

class FileService {
  var accountRepo = GetIt.I.get<AccountRepo>();
  var _dio = Dio();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    await new Directory('${directory.path}/.thumbnails').create(recursive: true);
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<File> _localThumbnailFile(String filename) async {
    final path = await _localPath;
    return File('$path/.thumbnails/$filename');
  }

  FileService() {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.baseUrl = "http://172.16.111.189:30010/";
      options.headers["Authorization"] = await accountRepo.getAccessToken();
      return options; //continue
    }));
  }

  Future<File> getFile(String uuid, String filename) async {
    Fimber.d("####################################################################");
    var res = await _dio.get("/$uuid/$filename",
        options: Options(responseType: ResponseType.bytes));
    final file = await _localFile(uuid);
    file.writeAsBytesSync(res.data);
    return file;
  }

  Future<File> getFileThumbnail(
      String uuid, String filename, ThumbnailSize size) async {
    Fimber.d("####################################################################");
    var res = await _dio.get("/${enumToString(size)}/$uuid/$filename",
        options: Options(responseType: ResponseType.bytes));
    final file = await _localThumbnailFile("${enumToString(size)}-$uuid");
    file.writeAsBytesSync(res.data);
    return file;
  }

  uploadFile(String filePath) async {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.onSendProgress = (int i, int j) {
        Fimber.d("upload " + ((i / j) * 100).toString() + "%");
      };
      return options; //continue
    }));

    var formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
    });

    return _dio.post("/upload", data: formData);
  }

  uploadFileList(List<String> filesPath) {
    for (String filePath in filesPath) {
      uploadFile(filePath);
    }
  }
}
