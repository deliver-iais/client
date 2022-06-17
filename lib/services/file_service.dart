import 'dart:io';
import 'dart:io' as io;

import 'package:clock/clock.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;

import 'ext_storage_services.dart';

enum ThumbnailSize { medium, small }

class FileService {
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();

  final _dio = Dio();
  Map<String, BehaviorSubject<double>> filesProgressBarStatus = {};

  Map<String, BehaviorSubject<CancelToken?>> cancelTokens = {};

  Future<String> get _localPath async {
    if (await _checkPermission.checkMediaLibraryPermission() ||
        isDesktop ||
        isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      if (!io.Directory('${directory.path}/Deliver').existsSync()) {
        await io.Directory('${directory.path}/Deliver').create(recursive: true);
      }
      return "${directory.path}/Deliver";
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<String> localFilePath(String fileUuid, String fileType) async {
    final path = await _localPath;
    return '$path/$fileUuid.$fileType';
  }

  Future<String> localThumbnailFilePath(
    String fileUuid,
    String fileType,
    ThumbnailSize size,
  ) async {
    final path = await _localPath;
    return "$path/${enumToString(size)}-$fileUuid.$fileType";
  }

  Future<io.File> localFile(String fileUuid, String fileType) async {
    final path = await _localPath;
    return io.File('$path/$fileUuid.$fileType');
  }

  Future<io.File> localThumbnailFile(
    String fileUuid,
    String fileType,
    ThumbnailSize size,
  ) async {
    return io.File(await localThumbnailFilePath(fileUuid, fileType, size));
  }

  FileService() {
    if (!isWeb) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = FileServiceBaseUrl;
          options.headers["Authorization"] = await _authRepo.getAccessToken();

          return handler.next(options); //continue
        },
      ),
    );
  }

  Future<String?> getFile(
    String uuid,
    String filename, {
    ThumbnailSize? size,
  }) async {
    if (size != null) {
      return _getFileThumbnail(uuid, filename, size);
    }
    return _getFile(uuid, filename);
  }

  Future<String?> _getFile(String uuid, String filename) async {
    if (filesProgressBarStatus[uuid] == null) {
      final d = BehaviorSubject<double>.seeded(0);
      filesProgressBarStatus[uuid] = d;
    }
    final cancelToken = CancelToken();
    cancelTokens[uuid] = BehaviorSubject.seeded(cancelToken);
    try {
      final res = await _dio.get(
        "/$uuid/$filename",
        onReceiveProgress: (i, j) {
          filesProgressBarStatus[uuid]!.add((i / j));
        },
        options: Options(responseType: ResponseType.bytes),
        cancelToken: cancelToken,
      );
      if (isWeb) {
        final blob = html.Blob(
          <Object>[res.data],
          "application/${filename.split(".").last}",
        );
        final url = html.Url.createObjectUrlFromBlob(blob);
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

  Future<void> saveDownloadedFile(String url, String filename) async {
    html.AnchorElement(href: url)
      ..download = url
      ..setAttribute("download", filename)
      ..click();
  }

  Future<io.File?> getDeliverIcon() async {
    final file = await localFile("deliver-icon", "png");
    if (file.existsSync()) {
      return file;
    } else {
      final res = await rootBundle
          .load('assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');
      final f = io.File("${await _localPath}/deliver-icon.png");
      try {
        await f.writeAsBytes(res.buffer.asInt8List());
        return f;
      } catch (e) {
        return null;
      }
    }
  }

  Future<void> saveFileInDownloadFolder(
    String path,
    String name,
    String directory,
  ) async {
    try {
      if (isWeb) {
        return saveDownloadedFile(path, name);
      } else {
        final downloadDir =
            await ExtStorage.getExternalStoragePublicDirectory(directory);
        final f = io.File('$downloadDir/$name');
        await f.writeAsBytes(io.File(path).readAsBytesSync());
      }
    } catch (_) {}
  }

  Future<String> _getFileThumbnail(
    String uuid,
    String filename,
    ThumbnailSize size,
  ) async {
    final cancelToken = CancelToken();
    cancelTokens[uuid] = BehaviorSubject.seeded(cancelToken);
    final res = await _dio.get(
      "/${enumToString(size)}/$uuid/.${filename.split('.').last}",
      options: Options(responseType: ResponseType.bytes),
      cancelToken: cancelToken,
    );
    if (isWeb) {
      final blob = html.Blob(
        <Object>[res.data],
        "application/${filename.split(".").last}",
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      return url;
    } else {
      final file =
          await localThumbnailFile(uuid, filename.split(".").last, size);
      file.writeAsBytesSync(res.data);
      return file.path;
    }
  }

  void initProgressBar(String uploadId) {
    if (filesProgressBarStatus[uploadId] == null) {
      filesProgressBarStatus[uploadId] = BehaviorSubject.seeded(0);
    }
  }

  Future<String> compressImageInDesktop(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final input = ImageFile(
        filePath: file.path,
        rawBytes: bytes,
      ); // set the input image file
      const config = Configuration(
        outputType: ImageOutputType.jpg,
        quality: 30,
      );

      final param = ImageFileConfiguration(input: input, config: config);
      final output = await compressor.compressJpg(param);
      final name = clock.now().millisecondsSinceEpoch.toString();
      final outPutFile = await localFile(name, "jpg");
      outPutFile.writeAsBytesSync(output.rawBytes);
      return outPutFile.path;
    } catch (_) {
      return file.path;
    }
  }

  Future<String> compressImageInMobile(
    File file,
  ) async {
    try {
      final name = clock.now().millisecondsSinceEpoch.toString();
      final targetFilePath = await localFilePath(name, "jpeg");
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetFilePath,
        quality: 60,
      );
      if (result != null) {
        return result.path;
      }
      return file.path;
    } catch (_) {
      return file.path;
    }
  }

  // TODO(hasan): refactoring needed,
  Future<Response<dynamic>?> uploadFile(
    String filePath,
    String filename, {
    String? uploadKey,
    void Function(int)? sendActivity,
  }) async {
    try {
      if (!isWeb) {
        try {
          final mediaType =
              MediaType.parse(mime(filePath) ?? filePath).toString();
          if (mediaType.contains("image") && !mediaType.endsWith("/gif")) {
            if (isAndroid || isIOS) {
              filePath = await compressImageInMobile(File(filePath));
            } else {
              filePath = await compressImageInDesktop(File(filePath));
            }
          }
        } catch (_) {
          _logger.e(_);
        }
      }
      final cancelToken = CancelToken();
      cancelTokens[uploadKey!] = BehaviorSubject.seeded(cancelToken);
      FormData? formData;
      if (isWeb) {
        final r = await http.get(
          Uri.parse(filePath),
        );
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            r.bodyBytes,
            contentType:
                MediaType.parse(mime(filename) ?? "application/octet-stream"),
          )
        });
      } else {
        formData = FormData.fromMap({
          "file": MultipartFile.fromFileSync(
            filePath,
            contentType:
                MediaType.parse(mime(filePath) ?? "application/octet-stream"),
          )
        });
      }

      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            options.onSendProgress = (i, j) {
              sendActivity?.call(i);
              if (filesProgressBarStatus[uploadKey] == null) {
                final d = BehaviorSubject<double>();
                filesProgressBarStatus[uploadKey] = d;
              }
              filesProgressBarStatus[uploadKey]!.add((i / j));
            };
            handler.next(options);
          },
        ),
      );
      return _dio.post("/upload", data: formData, cancelToken: cancelToken);
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  bool isFileFormatAccepted(String format) {
    format = format.toLowerCase();
    return format == "doc" ||
        format == "pdf" ||
        format == "svg" ||
        format == "csv" ||
        format == "xls" ||
        format == "txt" ||
        format == "jpg" ||
        format == "jpeg" ||
        format == "png" ||
        format == "gif" ||
        format == "txt" ||
        format == "rar" ||
        format == "zip" ||
        format == "mp3" ||
        format == "mp4" ||
        format == "m4a" ||
        format == "ogg" ||
        format == "xml" ||
        format == "pptx" ||
        format == "docx" ||
        format == "xlsm" ||
        format == "xlsx" ||
        format == "crt" ||
        format == "tgs" ||
        format == "apk" ||
        format == "mkv" ||
        format == "jfif" ||
        format == "webm";
  }
}
