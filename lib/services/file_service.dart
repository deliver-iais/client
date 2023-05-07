import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/storage_path_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/enum.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/files.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart';
import 'package:image_compression/image_compression.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart'
    as compress2;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;

enum ThumbnailSize { medium, large, frame }

enum FileStatus { NONE, STARTED, CANCELED, COMPLETED }

class FileService {
  final _storagePathService = GetIt.I.get<StoragePathService>();
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

  Future<String> localFilePath(String fileUuid, String fileType) async {
    final path = await _storagePathService.localPath;
    if (isWindowsNative) {
      return '$path\\$fileUuid.$fileType';
    }
    return '$path/$fileUuid.$fileType';
  }

  Future<String> localThumbnailFilePath(
    String fileUuid,
    String fileType,
    ThumbnailSize size,
  ) async {
    final path = await _storagePathService.localPath;
    return "$path/${enumToString(size)}-$fileUuid.$fileType";
  }

  Future<File> localFile(String fileUuid, String fileType) async {
    final path = await _storagePathService.localPath;
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
    bool showAlertOnError = false,
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
    return _getFile(
      uuid,
      filename,
      initProgressbar: initProgressbar,
      showAlertOnError: showAlertOnError,
    );
  }

  Future<String?> _getFile(
    String uuid,
    String filename, {
    bool initProgressbar = true,
    bool showAlertOnError = false,
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
        return Uri.dataFromBytes(res.data).toString();
      } else {
        final file = await localFile(
          uuid,
          filename.split('.').last,
        );
        file.writeAsBytesSync(res.data);
        return file.path;
      }
    } catch (e) {
      if ((e as DioError).type != DioErrorType.cancel && showAlertOnError) {
        Timer(
          const Duration(milliseconds: 500),
          () {
            ToastDisplay.showToast(
              toastText: _i18n.get("network_unavailable"),
            );
            updateFileStatus(uuid, FileStatus.CANCELED);
          },
        );
      } else {
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
      final f = File("${await _storagePathService.localPath}/we-icon.png");
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
      // Insure there is no desktop function call here!
      if (!isMobileNative) {
        return;
      }
      if (isAndroidNative) {
        final downloadDir =
            await _storagePathService.downloadDirPath(name, directory);
        File(
          downloadDir,
        ).writeAsBytesSync(
          name.endsWith(".webp")
              ? await convertImageToJpg(File(path))
              : File(path).readAsBytesSync(),
        );
      } else {
        if (isVideo(path)) {
          await GallerySaver.saveVideo(path);
        } else {
          await GallerySaver.saveImage(path);
        }
      }
    } catch (_) {
      _logger.e(_);
    }
  }

  Future<void> saveFileInDesktopDownloadFolder(
    String uuid,
    String name,
    String filePath,
  ) async {
    try {
      final file = await _downloadedFileDir(name.replaceAll(".webp", ".jpg"));
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
        return Uri.dataFromBytes(res.data).toString();
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

  Future<String> compressImageInWindows(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final input = ImageFile(
        filePath: file.path,
        rawBytes: bytes,
      ); // set the input image file
      const config = Configuration(
        jpgQuality: 30,
      );

      final param = ImageFileConfiguration(input: input, config: config);
      final output = await compressInQueue(param);
      final name = clock.now().millisecondsSinceEpoch.toString();
      final extension = getExtensionFromContentType(output.contentType)!;
      final outPutFile = await localFile(name, extension);
      outPutFile.writeAsBytesSync(output.rawBytes);
      return outPutFile.path;
    } catch (_) {
      return file.path;
    }
  }

  Future<String> compressImageInMacOrLinux(
    File file, {
    int quality = 30,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final input = ImageFile(
        filePath: file.path,
        rawBytes: bytes,
      ); // set the input image file
      final config = compress2.Configuration(
        quality: quality,
      );

      final param =
          compress2.ImageFileConfiguration(input: input, config: config);
      final output = await compress2.compressor.compressWebpThenJpg(param);
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
    String fileExtension,
  ) async {
    final f = await localFile(uploadKey, fileExtension);
    await f.writeAsBytes(file.readAsBytesSync());
    await _updateFileInfoWithNewPath(uploadKey, f.path);
  }

  Future<Response<dynamic>?> uploadFile(
    String filePath,
    String filename, {
    String? uploadKey,
    bool isVoice = false,
    void Function(int)? sendActivity,
  }) async {
    updateFileStatus(uploadKey!, FileStatus.STARTED);
    filename = getFileName(filename);
    filePath = normalizePath(filePath);

    final String size;
    late final Uint8List webBytes;
    if (isWeb) {
      webBytes = UriData.parse(filePath).contentAsBytes();
      size = webBytes.length.toString();
    } else {
      size = (File(filePath).lengthSync()).toString();
    }
    _logger.i("/checkUpload?fileName=$filename&fileSize=$size");
    final result =
        await _dio.get("/checkUpload?fileName=$filename&fileSize=$size");
    final Map<String, dynamic> decoded = jsonDecode(result.data);
    if (result.statusCode! == 200) {
      //add fileUploadToken to header
      final headers = _dio.options.headers;
      headers["UploadFileToken"] = decoded["token"] ?? "";
      _dio.options.headers = headers;
      try {
        final cancelToken = CancelToken();
        _addCancelToken(cancelToken, uploadKey);
        //concurrent save file in local directory
        if (isDesktopNative) {
          unawaited(
            _concurrentCloneFileInLocalDirectory(
              File(filePath),
              uploadKey,
              getFileExtension(filePath),
            ),
          );
        }
        FormData? formData;
        if (isWeb) {
          formData = FormData.fromMap({
            "file": MultipartFile.fromBytes(
              webBytes,
              filename: filename,
              contentType: filename.getMediaType(),
              headers: {
                Headers.contentLengthHeader: [webBytes.length.toString()],
              },
            )
          });
        } else {
          formData = FormData.fromMap({
            "file": MultipartFile.fromFileSync(
              filePath,
              contentType: filePath.getMediaType(),
              filename: filename,
              headers: {
                Headers.contentLengthHeader: [size], // set content-length
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
        final uploadUri = !isVoice
            ? "/uploadWithFileToken"
            : "/uploadWithFileToken?isVoice=true";
        return _dio.post(uploadUri, data: formData, cancelToken: cancelToken);
      } catch (e) {
        updateFileStatus(uploadKey, FileStatus.CANCELED);
        _logger.e(e);
        return null;
      }
    } else {
      return result;
    }
  }

  Future<model.File> compressFile(model.File file) async {
    if (!isWeb) {
      try {
        var filePath = file.path;
        if (isCompressibleImageFileType(file.path.getMimeString())) {
          if (isMobileNative) {
            filePath = await compressImageInMobile(File(file.path));
          } else {
            final time = clock.now().millisecondsSinceEpoch;
            if (isWindowsNative) {
              filePath = await compressImageInWindows(File(file.path));
            } else {
              filePath = await compressImageInMacOrLinux(File(file.path));
            }
            _logger.i(
              "compressTime : ${clock.now().millisecondsSinceEpoch - time}",
            );
          }
        }
        file = file.copyWith(
          name: getFileName(filePath),
          path: filePath,
          size: File(filePath).lengthSync(),
          extension: getFileExtension(filePath),
        );
      } catch (_) {
        _logger.e(_);
      }
    }
    return file;
  }
}
