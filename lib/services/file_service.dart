import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';

import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;

import 'ext_storage_services.dart';

enum ThumbnailSize { medium }

class FileService {
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();

  final _dio = Dio();
  Map<String, BehaviorSubject<double>> filesProgressBarStatus = {};

  Map<String, BehaviorSubject<CancelToken?>> cancelTokens = {};

  Future<String> get _localPath async {
    if (await _checkPermission.checkStoragePermission() ||
        isDesktop() ||
        isIOS()) {
      final directory = await getApplicationDocumentsDirectory();
      if (!await io.Directory('${directory.path}/Deliver').exists()) {
        await io.Directory('${directory.path}/Deliver').create(recursive: true);
      }
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

  Future<io.File> localFile(String fileUuid, String fileType) async {
    final path = await _localPath;
    return io.File('$path/$fileUuid.$fileType');
  }

  Future<io.File> localThumbnailFile(
      String fileUuid, String fileType, ThumbnailSize size) async {
    return io.File(await localThumbnailFilePath(fileUuid, fileType, size));
  }

  FileService() {
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
   };
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      options.baseUrl = FileServiceBaseUrl;
      options.headers["Authorization"] = await _authRepo.getAccessToken();

      return handler.next(options); //continue
    }));
  }

  Future<String?> getFile(String uuid, String filename,
      {ThumbnailSize? size}) async {
    if (size != null) {
      return _getFileThumbnail(uuid, filename, size);
    }
    return _getFile(uuid, filename);
  }

  Future<String?> _getFile(String uuid, String filename) async {
    if (filesProgressBarStatus[uuid] == null) {
      BehaviorSubject<double> d = BehaviorSubject.seeded(0);
      filesProgressBarStatus[uuid] = d;
    }
    CancelToken cancelToken = CancelToken();
    cancelTokens[uuid] = BehaviorSubject.seeded(cancelToken);
    try {
      var res = await _dio.get("/$uuid/$filename", onReceiveProgress: (i, j) {
        filesProgressBarStatus[uuid]!.add((i / j));
      },
          options: Options(responseType: ResponseType.bytes),
          cancelToken: cancelToken);
      if (kIsWeb) {
        var blob = html.Blob(
            <Object>[res.data], "application/${filename.split(".").last}");
        var url = html.Url.createObjectUrlFromBlob(blob);
        return url;
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
    html.AnchorElement(href: url)
      ..download = url
      ..setAttribute("download", filename)
      ..click();
  }

  Future<io.File?> getDeliverIcon() async {
    var file = await localFile("deliver-icon", "png");
    if (file.existsSync()) {
      return file;
    } else {
      var res = await rootBundle
          .load('assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');
      io.File f = io.File("${await _localPath}/deliver-icon.png");
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
      io.File f = io.File('$downloadDir/$name');
      try {
        await f.writeAsBytes(io.File(path).readAsBytesSync());
      } catch (_) {}
    }
  }

  Future<String> _getFileThumbnail(
      String uuid, String filename, ThumbnailSize size) async {
    CancelToken cancelToken = CancelToken();
    cancelTokens[uuid] = BehaviorSubject.seeded(cancelToken);
    var res = await _dio.get(
      "/${enumToString(size)}/$uuid/.${filename.split('.').last}",
      options: Options(responseType: ResponseType.bytes),
      cancelToken: cancelToken,
    );
    final file = await localThumbnailFile(uuid, filename.split(".").last, size);
    file.writeAsBytesSync(res.data);
    return file.path;
  }

  void initProgressBar(String uploadId) {
    if (filesProgressBarStatus[uploadId] == null) {
      filesProgressBarStatus[uploadId] = BehaviorSubject.seeded(0);
    }
  }

  // TODO, refactoring needed
  uploadFile(String filePath, String filename,
      {String? uploadKey, Function? sendActivity}) async {
    try {
      CancelToken cancelToken = CancelToken();
      cancelTokens[uploadKey!] = BehaviorSubject.seeded(cancelToken);
      FormData? formData;
      if (kIsWeb) {
        http.Response r = await http.get(
          Uri.parse(filePath),
        );
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(r.bodyBytes,
              contentType:
                  MediaType.parse(mime(filename) ?? "application/octet-stream"))
        });
      } else {
        formData = FormData.fromMap({
          "file": MultipartFile.fromFileSync(filePath,
              contentType:
                  MediaType.parse(mime(filePath) ?? "application/octet-stream"),
              )
        });
      }

      _dio.interceptors.add(InterceptorsWrapper(onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        options.onSendProgress = (int i, int j) {
          if (sendActivity != null) sendActivity(i);
          if (filesProgressBarStatus[uploadKey] == null) {
            BehaviorSubject<double> d = BehaviorSubject();
            filesProgressBarStatus[uploadKey] = d;
          }
          filesProgressBarStatus[uploadKey]!.add((i / j));
        };
        handler.next(options);
      }));
      return _dio.post("/upload", data: formData, cancelToken: cancelToken);
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }
}
