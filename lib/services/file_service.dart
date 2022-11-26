import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/localization/i18n.dart';
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
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;

import 'ext_storage_services.dart';

enum ThumbnailSize { medium, small }

enum FileStatus { NONE, STARTED, CANCELED, COMPLETED }

class FileService {
  final _checkPermission = GetIt.I.get<CheckPermissionsService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileDao = GetIt.I.get<FileDao>();
  final _logger = GetIt.I.get<Logger>();
  final _i18n = GetIt.I.get<I18N>();

  final _dio = Dio();

  final List<String> canceledUploadUuids = [];

  void _addCancelUploadFile(String uuid) {
    canceledUploadUuids.add(uuid);
  }

  final BehaviorSubject<Map<String, FileStatus>> _fileStatus =
      BehaviorSubject.seeded({});

  Stream<Map<String, FileStatus>> watchFileStatus() => _fileStatus;

  FileStatus getFileStatus(String uuid) =>
      _fileStatus.value[uuid] ?? FileStatus.NONE;

  void updateFileStatus(String uuid, FileStatus status) =>
      _fileStatus.add(_fileStatus.value..[uuid] = status);

  final BehaviorSubject<Map<String, CancelToken>> _cancelTokens =
      BehaviorSubject.seeded({});

  BehaviorSubject<Map<String, double>> filesProgressBarStatus =
      BehaviorSubject.seeded({});

  void cancelUploadOrDownloadFile(String uuid) {
    if (_cancelTokens.value[uuid] != null) {
      _cancelTokens.value[uuid]?.cancel("cancelled");
    } else {
      _addCancelUploadFile(uuid);
    }
    filesProgressBarStatus.add(filesProgressBarStatus.value..[uuid] = 0.0);
    updateFileStatus(uuid, FileStatus.CANCELED);
  }

  void _addCancelToken(CancelToken cancelToken, String uuid) {
    final map = _cancelTokens.value;
    map[uuid] = cancelToken;
    _cancelTokens.add(map);
  }

  void _cancelUploadFile() {
    try {
      _cancelTokens.listen((cancelTokens) {
        for (final uuid in cancelTokens.keys) {
          if (canceledUploadUuids.contains(uuid)) {
            cancelTokens[uuid]?.cancel("cancelled");
            canceledUploadUuids.remove(uuid);
          }
        }
      });
    } catch (e) {
      _logger.e(e);
    }
  }

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

  Future<File> _downloadedFileDir(String filePath) async {
    final directory = await getDownloadsDirectory();
    await Directory('${directory!.path}/$APPLICATION_FOLDER_NAME')
        .create(recursive: true);
    return File("${directory.path}/$APPLICATION_FOLDER_NAME/$filePath");
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
          options.headers["Accept-Language"] = _i18n.locale.languageCode;
          return handler.next(options); //continue
        },
      ),
    );
    _cancelUploadFile();
  }

  Future<String?> getFile(
    String uuid,
    String filename, {
    ThumbnailSize? size,
    bool initProgressbar = true,
  }) async {
    if (initProgressbar) {
      updateFileStatus(uuid, FileStatus.STARTED);
    }

    if (size != null) {
      return _getFileThumbnail(
        uuid,
        filename,
        size,
        initProgressbar: initProgressbar,
      );
    }
    return _getFile(uuid, filename, initProgressbar: initProgressbar);
  }

  Future<String?> _getFile(
    String uuid,
    String filename, {
    bool initProgressbar = true,
  }) async {
    final cancelToken = CancelToken();
    _addCancelToken(cancelToken, uuid);

    try {
      final res = await _dio.get(
        "/$uuid/$filename",
        onReceiveProgress: (i, j) {
          if (initProgressbar) {
            if (filesProgressBarStatus.value[uuid] == null) {
              filesProgressBarStatus
                  .add(filesProgressBarStatus.value..[uuid] = 0);
            }
            filesProgressBarStatus
                .add(filesProgressBarStatus.value..[uuid] = (i / j));
          }
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
      if (initProgressbar) {
        updateFileStatus(uuid, FileStatus.CANCELED);
      }

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

  Future<void> saveFileInMobileDownloadFolder(
    String path,
    String name,
    String directory,
  ) async {
    try {
      final downloadDir =
          await ExtStorage.getExternalStoragePublicDirectory(directory);
      await Directory('$downloadDir/$APPLICATION_FOLDER_NAME')
          .create(recursive: true);
      File(
        '$downloadDir/$APPLICATION_FOLDER_NAME/${name.replaceAll(".webp", ".jpg")}',
      ).writeAsBytesSync(
        name.endsWith(".webp")
            ? await convertImageToJpg(File(path))
            : File(path).readAsBytesSync(),
      );
    } catch (_) {}
  }

  Future<void> saveFileInDesktopDownloadFolder(
    String uuid,
    String name,
    String filePath,
  ) async {
    try {
      final file = await _downloadedFileDir(
        name.replaceAll(".webp", ".jpg"),
      );
      file.writeAsBytesSync(
        name.endsWith(".webp")
            ? (await convertImageToJpg(File(filePath)))
            : File(filePath).readAsBytesSync(),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> saveFileToSpecifiedAddress(
    String path,
    String address, {
    bool convertToJpg = true,
  }) async {
    try {
      final fileFormat = path.split(".").last;
      final ad = (fileFormat != address.split(".").last)
          ? "$address.$fileFormat"
          : address;
      File(ad.replaceAll(".webp", ".jpg")).writeAsBytesSync(
        convertToJpg && path.endsWith(".webp")
            ? await convertImageToJpg(File(path))
            : File(path).readAsBytesSync(),
      );
    } catch (_) {}
  }

  Future<String?> _getFileThumbnail(
    String uuid,
    String filename,
    ThumbnailSize size, {
    bool initProgressbar = true,
  }) async {
    try {
      final cancelToken = CancelToken();
      _addCancelToken(cancelToken, uuid);

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
    } catch (e) {
      if (initProgressbar) {
        updateFileStatus(uuid, FileStatus.CANCELED);
      }

      _logger.e(e);
      return null;
    }
  }

  Future<List<int>> convertImageToJpg(File file) async {
    final image = decodeImage(file.readAsBytesSync())!;
    return encodeJpg(image);
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

  bool fileInProgress() {
    return false;
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

  Future<Response<dynamic>?> uploadFile(
    String filePath,
    String filename, {
    String? uploadKey,
    void Function(int)? sendActivity,
  }) async {
    updateFileStatus(uploadKey!, FileStatus.STARTED);
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
      _addCancelToken(cancelToken, uploadKey);
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
        final file = Uint8List.fromList(filePath.codeUnits);

        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            file.toList(),
            filename: filename,
            contentType:
                MediaType.parse(mime(filename) ?? "application/octet-stream"),
            headers: {
              Headers.contentLengthHeader: [
                file.length.toString()
              ], // set content-length
            },
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
                if (filesProgressBarStatus.value[uploadKey] == null) {
                  filesProgressBarStatus
                      .add(filesProgressBarStatus.value..[uploadKey] = 0);
                }
                filesProgressBarStatus.add(
                  filesProgressBarStatus.value..[uploadKey] = (i / j),
                );
              }
            };
            handler.next(options);
          },
        ),
      );
      return _dio.post("/upload", data: formData, cancelToken: cancelToken);
    } catch (e) {
      updateFileStatus(uploadKey, FileStatus.CANCELED);
      _logger.e(e);
      return null;
    }
  }

  bool isFileFormatAccepted(String format) {
    format = format.toLowerCase();
    return format == "mp3" ||
        format == "mp4" ||
        format == "pdf" ||
        format == "jpeg" ||
        format == "jpg" ||
        format == "apk" ||
        format == "txt" ||
        format == "doc" ||
        format == "docx" ||
        format == "zip" ||
        format == "rar" ||
        format == "webp" ||
        format == "ogg" ||
        format == "svg" ||
        format == "csv" ||
        format == "xls" ||
        format == "gif" ||
        format == "png" ||
        format == "m4a" ||
        format == "xml" ||
        format == "pptx" ||
        format == "xlsm" ||
        format == "xlsx" ||
        format == "crt" ||
        format == "tgs" ||
        format == "mkv" ||
        format == "jfif" ||
        format == "ico" ||
        format == "wav" ||
        format == "opus" ||
        format == "pem" ||
        format == "ipa" ||
        format == "tar" ||
        format == "gzip" ||
        format == "psd" ||
        format == "env" ||
        format == "exe" ||
        format == "json" ||
        format == "html" ||
        format == "css" ||
        format == "scss" ||
        format == "js" ||
        format == "ts" ||
        format == "java" ||
        format == "kt" ||
        format == "yaml" ||
        format == "yml" ||
        format == "properties" ||
        format == "srt" ||
        format == "py" ||
        format == "conf" ||
        format == "config" ||
        format == "icns" ||
        format == "dart" ||
        format == "c" ||
        format == "md" ||
        format == "bmp" ||
        format == "pom" ||
        format == "jar" ||
        format == "msi" ||
        format == "webm";
  }
}
