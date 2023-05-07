import 'dart:async';
import 'dart:io';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/check_permissions_service.dart';
import 'ext_storage_services.dart';

class StoragePathService {
  final MethodChannel _channel = const MethodChannel('read_external');

  final _checkPermission = GetIt.I.get<CheckPermissionsService>();

  String? _imagePath;
  String? _videoPath;
  String? _audioPath;
  String? _filePath;
  String? _localPath;
  String? _isarLocalPath;
  String? _downloadDirPath;

  Future<String> _calculateImagePath() async {
    try {
      _imagePath = await _channel.invokeMethod('get_all_image');
      return _imagePath!;
    } catch (e) {
      return "";
    }
  }

  Future<String> _calculateVideoPath() async {
    _videoPath = await _channel.invokeMethod('get_all_video');
    return _videoPath!;
  }

  Future<String> _calculateAudioPath() async {
    _audioPath = await _channel.invokeMethod('get_all_music');
    return _audioPath!;
  }

  Future<String> _calculateFilePath() async {
    _filePath = await _channel.invokeMethod('get_all_file');
    return _filePath!;
  }

  Future<String> _calculateLocalPath() async {
    if (isDesktopNative ||
        isIOSNative ||
        await _checkPermission.checkMediaLibraryPermission()) {
      _localPath = await _getDirectoryPath();
      return _localPath!;
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<String> _calculateLocalPathIsar() async {
    if (isDesktopNative ||
        isIOSNative ||
        await _checkPermission.checkMediaLibraryPermission()) {
      _isarLocalPath = await _getSupportedDirectoryPath(additionalPath: "db");
      return _isarLocalPath!;
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<String> _getSupportedDirectoryPath({
    String additionalPath = "",
  }) async {
    final directory = await getApplicationSupportDirectory();
    if (!Directory('${directory.path}/$additionalPath').existsSync()) {
      await Directory(
        '${directory.path}/$additionalPath',
      ).create(recursive: true);
    }
    if (isWindowsNative) {
      return "${directory.path}\\$additionalPath";
    }
    return "${directory.path}/$additionalPath";
  }

  Future<String> _getDirectoryPath({
    String additionalPath = "",
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Directory('${directory.path}/$APPLICATION_FOLDER_NAME$additionalPath')
        .existsSync()) {
      await Directory(
        '${directory.path}/$APPLICATION_FOLDER_NAME$additionalPath',
      ).create(recursive: true);
    }
    if (isWindowsNative) {
      return "${directory.path}\\$APPLICATION_FOLDER_NAME${additionalPath.replaceAll("/", "\\")}";
    }
    return "${directory.path}/$APPLICATION_FOLDER_NAME$additionalPath";
  }

  Future<String> _calculateDownloadDir(
    String name,
    String directory,
  ) async {
    if (await _checkPermission.checkStoragePermission()) {
      final downloadDir =
          await ExtStorage.getExternalStoragePublicDirectory(directory);
      await Directory('$downloadDir/$APPLICATION_FOLDER_NAME')
          .create(recursive: true);
      _downloadDirPath =
          '$downloadDir/$APPLICATION_FOLDER_NAME/${name.replaceAll(
        ".webp",
        ".jpg",
      )}';
      return _downloadDirPath!;
    }
    throw Exception("There is no Storage Permission!");
  }

  Future<String> get imagesPath async =>
      _imagePath ?? await _calculateImagePath();

  Future<String> get videoPath async =>
      _videoPath ?? await _calculateVideoPath();

  Future<String> get audioPath async =>
      _audioPath ?? await _calculateAudioPath();

  Future<String> get filePath async => _filePath ?? await _calculateFilePath();

  Future<String> get localPath async =>
      _localPath ?? await _calculateLocalPath();

  Future<String> get localPathIsar async =>
      _isarLocalPath ?? await _calculateLocalPathIsar();

  Future<String> downloadDirPath(
    String name,
    String directory,
  ) async =>
      _downloadDirPath ?? await _calculateDownloadDir(name, directory);
}
