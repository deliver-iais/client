import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/constants.dart';
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
  final _fileDao = GetIt.I.get<FileDao>();
  final _logger = GetIt.I.get<Logger>();

  final _dio = Dio();
  Map<String, BehaviorSubject<double>> filesProgressBarStatus = {};

  Map<String, BehaviorSubject<CancelToken?>> cancelTokens = {};

  Future<String> get _localPath async {
    if (await _checkPermission.checkMediaLibraryPermission() ||
        isDesktop ||
        isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      if (!Directory('${directory.path}/$APPLICATION_FOLDER_NAME')
          .existsSync()) {
        await Directory('${directory.path}/$APPLICATION_FOLDER_NAME')
            .create(recursive: true);
      }
      if (isWindows) {
        return "${directory.path}\\$APPLICATION_FOLDER_NAME";
      }
      return "${directory.path}/$APPLICATION_FOLDER_NAME";
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<String> localFilePath(String fileUuid, String fileType) async {
    final path = await _localPath;
    if (isWindows) {
      return '$path\\$fileUuid.$fileType';
    }
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

  Future<File> localFile(String fileUuid, String fileType) async {
    final path = await _localPath;
    return File('$path/$fileUuid.$fileType');
  }

  Future<File> localThumbnailFile(
    String fileUuid,
    String fileType,
    ThumbnailSize size,
  ) async {
    return File(await localThumbnailFilePath(fileUuid, fileType, size));
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
          options.baseUrl =
              GetIt.I.get<ServicesDiscoveryRepo>().fileServiceBaseUrl;
          options.headers["Authorization"] = await _authRepo.getAccessToken();
          options.headers["service"] = "ms-file";

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
        final file = await localFile(
          uuid,
          filename.split('.').last,
        );
        file.writeAsBytesSync(res.data);
        return file.path;
      }
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  void saveDownloadedFile(String url, String filename) {
    try {
      html.AnchorElement(href: url)
        ..download = url
        ..setAttribute("download", filename)
        ..click();
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<File?> getApplicationIcon() async {
    final file = await localFile("we-icon", "png");
    if (file.existsSync()) {
      return file;
    } else {
      final res = await rootBundle
          .load('assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');
      final f = File("${await _localPath}/we-icon.png");
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
      final downloadDir =
          await ExtStorage.getExternalStoragePublicDirectory(directory);
      final f = File('$downloadDir/${name.replaceAll(".webp", ".jpg")}');
      await f.writeAsBytes(File(path).readAsBytesSync());
    } catch (_) {}
  }

  Future<void> saveFileToSpecifiedAddress(
    String path,
    String name,
    String address,
  ) async {
    try {
      final f = File(address);
      await f.writeAsBytes(File(path).readAsBytesSync());
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
        quality: 30,
      );

      final param = ImageFileConfiguration(input: input, config: config);
      final output = await compressor.compressWebpThenJpg(param);
      final name = clock.now().millisecondsSinceEpoch.toString();
      final extension = getExtensionFromContentType(output.contentType)!;
      final outPutFile = await localFile(name, extension);
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
      final targetFilePath = await localFilePath(name, "webp");
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetFilePath,
        quality: 60,
        format: CompressFormat.webp,
      );
      if (result != null) {
        return result.path;
      }
      return file.path;
    } catch (_) {
      return file.path;
    }
  }

  String? getExtensionFromContentType(String? contentType) {
    if (contentType == null) {
      return null;
    }
    final parts = contentType.split('/');
    if (parts.length == 2) {
      return parts[1].toLowerCase();
    }

    return null;
  }

  Future<FileInfo?> _getFileInfoInDB(String size, String uuid) async =>
      _fileDao.get(uuid, enumToString(size));

  Future<void> _updateFileInfoWithNewPath(
    String uploadKey,
    String path,
  ) async {
    final real = await _getFileInfoInDB("real", uploadKey);
    final medium = await _getFileInfoInDB("medium", uploadKey);

    await _fileDao.remove(real!);
    if (medium != null) {
      await _fileDao.remove(medium);
    }

    await _fileDao.save(real.copyWith(path: path, uuid: real.uuid));

    if (medium != null) {
      await _fileDao.save(medium.copyWith(path: path, uuid: medium.uuid));
    }
  }

  Future<void> _concurrentCloneFileInLocalDirectory(
    File file,
    String uploadKey,
    String fileType,
  ) async {
    final f = await localFile(uploadKey, fileType);
    await f.writeAsBytes(file.readAsBytesSync());
    await _updateFileInfoWithNewPath(uploadKey, f.path);
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
          if (isWindows) {
            filePath = filePath.replaceAll("\\", "/");
          }
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
      //concurrent save file in local directory
      if (isDesktop) {
        unawaited(
          _concurrentCloneFileInLocalDirectory(
            File(filePath),
            uploadKey,
            MediaType.parse(mime(filePath) ?? filePath).subtype,
          ),
        );
      }
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
            headers: {
              Headers.contentLengthHeader: [
                (File(filePath).lengthSync()).toString()
              ], // set content-length
            },
          )
        });
      }

      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            options.onSendProgress = (i, j) {
              if (i / j < 1) {
                sendActivity?.call(i);
                if (filesProgressBarStatus[uploadKey] == null) {
                  final d = BehaviorSubject<double>();
                  filesProgressBarStatus[uploadKey] = d;
                }
                filesProgressBarStatus[uploadKey]!.add((i / j));
              }
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
        format == "webm" ||
        format == "webp";
  }
}
