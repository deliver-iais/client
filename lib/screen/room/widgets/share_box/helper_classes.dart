import 'dart:convert';
import 'dart:io';

import 'package:deliver/services/storage_path.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class FileBasic {
  final String path;

  FileBasic({required this.path});
}

class AudioItem extends FileBasic {
  final String title;

  AudioItem({required super.path, required this.title});

  static Future<List<File>> getAudios() async {
    final storageFiles = await StoragePath.audioPath;
    final List<dynamic> paths = json.decode(storageFiles);

    final files = <File>[];
    for (final path in paths) {
      try {
        files.add(File(path.toString()));
      } catch (e) {
        GetIt.I.get<Logger>().e(e);
      }
    }
    return files;
  }
}

class FileItem extends FileBasic {
  FileItem({required super.path});

  static Future<List<String>> getFiles() async {
    try {
      final storageFiles = await StoragePath.filePath;
      final List<dynamic> filesPath = json.decode(storageFiles);
      final result = <String>[];
      for (final path in filesPath) {
        result.add(path.toString());
      }
      return result;
    } catch (e) {
      GetIt.I.get<Logger>().e(e);
      return [];
    }
  }
}
