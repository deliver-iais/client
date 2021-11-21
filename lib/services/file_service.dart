import 'dart:io';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

enum ThumbnailSize { medium }

class FileService {
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  var _dio = Dio();
  Map<String, BehaviorSubject<double>> filesUploadStatus = Map();

  Map<String, BehaviorSubject<double>> filesDownloadStatus = Map();

  Future<String> get _localPath async {
    if (await _checkPermission.checkStoragePermission() ||
        isDesktop() ||
        isIOS()) {
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
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      options.baseUrl = FileServiceBaseUrl;
      options.headers["Authorization"] = await _authRepo.getAccessToken();
      return handler.next(options); //continue
    }));
  }

  Future<File> getFile(String uuid, String filename,
      {ThumbnailSize? size}) async {
    if (size != null) {
      return _getFileThumbnail(uuid, filename, size);
    }
    return _getFile(uuid, filename);
  }

  // TODO, refactoring needed
  Future<File> _getFile(String uuid, String filename) async {
    if (filesDownloadStatus[uuid] == null) {
      BehaviorSubject<double> d = BehaviorSubject.seeded(0);
      filesDownloadStatus[uuid] = d;
    }
    var res = await _dio.get("/$uuid/$filename", onReceiveProgress: (i, j) {
      filesDownloadStatus[uuid]!.add((i / j));
    }, options: Options(responseType: ResponseType.bytes));
    final file = await localFile(uuid, filename.split('.').last);
    file.writeAsBytesSync(res.data);
    return file;
  }

  Future<File?> getDeliverIcon() async {
    var file = await localFile("deliver-icon", "png");
    if (file.existsSync()) {
      return file;
    } else {
      var res = await rootBundle
          .load('assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');
      File f = File("${await _localPath}/deliver-icon.png");
      try {
        await f.writeAsBytes(res.buffer.asInt8List());
        return f;
      } catch (e) {
        return null;
      }
    }
  }

  saveFileInDownloadFolder(File file, String name, String directory) async {
    var downloadDir =
        await ExtStorage.getExternalStoragePublicDirectory(directory);
    File f = File('$downloadDir/$name');
    try {
      await f.writeAsBytes(file.readAsBytesSync());
    } catch (e) {}
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

  void initUpoadProgrss(String uploadId) {
    BehaviorSubject<double> behaviorSubject = BehaviorSubject.seeded(0);
    filesUploadStatus[uploadId] = behaviorSubject;
  }

  // TODO, refactoring needed
  uploadFile(String filePath,
      {required String uploadKey, Function? sendActivity}) async {
    // var file = await http.MultipartFile.fromPath("image", filePath,
    //     contentType: MediaType.parse(mime(filePath)));
    // try {
    //   var request = new http.MultipartRequest(
    //       "POST", Uri.parse(FileServiceBaseUrl+"/upload"));
    //   request.headers["Authorization"] = await _authRepo.getAccessToken();
    //   request.headers["Content-type"] = "multipart/form-data";
    //   request.files.add(file);
    //   var res = await request.send();
    //   print(res.statusCode);
    // } catch (e) {
    //   print(e.toString());
    // }
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      options.onSendProgress = (int i, int j) {
        if (sendActivity != null) sendActivity();
        if (filesUploadStatus[uploadKey] == null) {
          BehaviorSubject<double> d = BehaviorSubject();
          filesUploadStatus[uploadKey] = d;
        }
        filesUploadStatus[uploadKey]!.add((i / j));
      };
      handler.next(options);
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
