import 'dart:io';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http_parser/http_parser.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/shared/methods/enum_helper_methods.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

enum ThumbnailSize { small, medium, large }

class FileService {
  var _checkPermission = GetIt.I.get<CheckPermissionsService>();
  var accountRepo = GetIt.I.get<AccountRepo>();

  var _dio = Dio();
  Map<String, BehaviorSubject<double>> filesUploadStatus = Map();

  Map<String, BehaviorSubject<double>> filesDownloadStatus = Map();

  Future<String> get _localPath async {
    if (await _checkPermission.checkStoragePermission() || isDesktop()) {
      final directory = await getApplicationDocumentsDirectory();
      if (!await Directory('${directory.path}/Deliver').exists())
        await Directory('${directory.path}/Deliver').create(recursive: true);
      return directory.path + "/Deliver";
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<String> localFilePath(String fileUuid, String fileType) async {
    final path = await _localPath;
    return '$path/$fileUuid.$fileType';
  }

  Future<String> localThumbnailFilePath(
      String fileUuid, String fileType, ThumbnailSize size) async {
    final path = await _localPath;
    return "$path/${enumToString(size)}-$fileUuid.$fileType";
  }

  Future<File> localFile(String fileUuid, String fileType) async {
    final path = await _localPath;
    return File('$path/$fileUuid.$fileType');
  }

  Future<File> localThumbnailFile(
      String fileUuid, String fileType, ThumbnailSize size) async {
    return File(await localThumbnailFilePath(fileUuid, fileType, size));
  }

  FileService() {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.baseUrl = FileServiceBaseUrl;
      options.headers["Authorization"] = await accountRepo.getAccessToken();
      return options; //continue
    }));
  }

  Future<File> getFile(String uuid, String filename,
      {ThumbnailSize size}) async {
    if (size != null) {
      return _getFileThumbnail(uuid, filename, size);
    }
    return _getFile(uuid, filename);
  }

  // TODO, refactoring needed
  Future<File> _getFile(String uuid, String filename) async {
    BehaviorSubject<double> behaviorSubject = BehaviorSubject();
    var res = await _dio.get("/$uuid/$filename", onReceiveProgress: (i, j) {
      behaviorSubject.add((i / j));
      filesDownloadStatus[uuid] = behaviorSubject;
    }, options: Options(responseType: ResponseType.bytes));
    final file = await localFile(uuid, filename.split('.').last);
    file.writeAsBytesSync(res.data);
    return file;
  }

  Future<File> _getFileThumbnail(
      String uuid, String filename, ThumbnailSize size) async {
    var res = await _dio.get(
        "/${enumToString(size)}/$uuid/.${filename.split('.').last}",
        options: Options(responseType: ResponseType.bytes));
    final file = await localThumbnailFile(uuid, filename.split(".").last, size);
    file.writeAsBytesSync(res.data);
    return file;
  }
  void initUpoadProgrss(String uploadId){
    BehaviorSubject<double> behaviorSubject = BehaviorSubject();
    filesUploadStatus[uploadId] = behaviorSubject;

  }


  // TODO, refactoring needed
  uploadFile(String filePath, {String uploadKey, Function sendActivity}) async {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.onSendProgress = (int i, int j) {
        sendActivity();
        filesUploadStatus[uploadKey].add((i/j)) ;
      };
      return options; //continue
    }));

    var formData = FormData.fromMap({
      "file": MultipartFile.fromFileSync(filePath,
          contentType:
              MediaType.parse(mime(filePath) ?? "application/octet-stream")),
    });

    return _dio.post(
      "/upload",
      data: formData,
    );
  }
}
