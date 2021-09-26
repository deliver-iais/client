import 'dart:html' as html;
import 'dart:js' as js;

import 'dart:io';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

enum ThumbnailSize { medium }

class FileService {
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();

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
      options.headers["Access-Control-Allow-Origin"] = "*";
      options.headers["Access-Control-Allow-Credentials"] = true;
      options.headers["Access-Control-Allow-Headers"] =
          "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token";
      options.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS";

      return handler.next(options); //continue
    }));
  }

  Future<String> getFile(String uuid, String filename,
      {ThumbnailSize size}) async {
    if (size != null) {
      return _getFileThumbnail(uuid, filename, size);
    }
    return _getFile(uuid, filename);
  }

  // TODO, refactoring needed
  Future<String> _getFile(String uuid, String filename) async {
    if (filesDownloadStatus[uuid] == null) {
      BehaviorSubject<double> d = BehaviorSubject.seeded(0);
      filesDownloadStatus[uuid] = d;
    }
    try {
      var res = await _dio.get("/$uuid/$filename", onReceiveProgress: (i, j) {
        filesDownloadStatus[uuid].add((i / j));
      }, options: Options(responseType: ResponseType.bytes));
      if (kIsWeb) {
        var blob = html.Blob(
            <Object>[res.data], "application/${filename.split(".").last}");
        var result = html.Url.createObjectUrlFromBlob(blob);
        var anchorElement = html.AnchorElement(
          href: result,
        )
          ..download = result
          ..slot = blob.toString()
          ..title = uuid
          ..setAttribute("download", filename);
        html.document.body.children.add(anchorElement);
        html.window.indexedDB
        return result;
      } else {
        final file = await localFile(uuid, filename.split('.').last);
        file.writeAsBytesSync(res.data);
        return file.path;
      }
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  saveDownloadedFile(String url, String filename) async {
    html.AnchorElement(
      href: url,
    )
      ..download = url
      ..setAttribute("download", filename)
      ..click();
  }

  Future<File> getDeliverIcon() async {
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

  saveFileInDownloadFolder(String path, String name, String directory) async {
    if (kIsWeb) {
      saveDownloadedFile(path, name);
    } else {
      var downloadDir =
          await ExtStorage.getExternalStoragePublicDirectory(directory);
      File f = File('$downloadDir/$name');
      try {
        await f.writeAsBytes(File(path).readAsBytesSync());
      } catch (e) {}
    }
  }

  Future<String> _getFileThumbnail(
      String uuid, String filename, ThumbnailSize size) async {
    var res = await _dio.get(
        "/${enumToString(size)}/$uuid/.${filename.split('.').last}",
        options: Options(responseType: ResponseType.bytes));
    final file = await localThumbnailFile(uuid, filename.split(".").last, size);
    file.writeAsBytesSync(res.data);
    return file.path;
  }

  void initUpoadProgrss(String uploadId) {
    BehaviorSubject<double> behaviorSubject = BehaviorSubject.seeded(0);
    filesUploadStatus[uploadId] = behaviorSubject;
  }

  // TODO, refactoring needed
  uploadFile(String filePath, String filename,
      {String uploadKey, Function sendActivity}) async {
    try {
      http.Response response = await http.get(
        Uri.parse(filePath),
      );
      _dio.interceptors.add(InterceptorsWrapper(onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        options.onSendProgress = (int i, int j) {
          if (sendActivity != null) sendActivity();
          if (filesUploadStatus[uploadKey] == null) {
            BehaviorSubject<double> d = BehaviorSubject();
            filesUploadStatus[uploadKey] = d;
          }
          filesUploadStatus[uploadKey].add((i / j));
        };
        handler.next(options);
      }));

      var formData = FormData.fromMap({
        "file": kIsWeb
            ? MultipartFile.fromBytes(response.bodyBytes,
                filename: filename,
                contentType: MediaType.parse(
                    mime(filePath) ?? "application/octet-stream"))
            : MultipartFile.fromFileSync(filePath,
                contentType: MediaType.parse(
                    mime(filePath) ?? "application/octet-stream")),
      });

      return _dio.post(
        "/upload",
        data: formData,
      );
    } catch (e) {
      _logger.e(e);
    }
  }
}
