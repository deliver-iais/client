import 'dart:convert';
import 'dart:io';

import 'package:date_time_format/date_time_format.dart';
import 'package:deliver/services/storage_path.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class StorageFile {
  final List files;
  final String folderName;

  const StorageFile({required this.files, required this.folderName});

  factory StorageFile.fromJson(Map<String, dynamic> json) {
    return StorageFile(
        files: json['files'] as List,
        folderName: json['folderName'].toString());
  }
}

List<StorageFile> _storageFiles(String json) {
  return jsonDecode(json)
      .map<StorageFile>((json) => StorageFile.fromJson(json))
      .toList();
}

class FileBasic {
  final String path;

  FileBasic(this.path);
}

class AudioItem extends FileBasic {
  final String title;

  AudioItem({required String path, required this.title}) : super(path);

  static Future<List<File>> getAudios() async {
    var storageFiles = await StoragePath.audioPath;
    List<dynamic> paths = json.decode(storageFiles);

    List<File> files = [];
    for (var path in paths) {
      try {
        files.add(File(path.toString()));
      } catch (e) {
        GetIt.I.get<Logger>().e(e);
      }
    }
    return files;
  }
}

class ImageItem extends FileBasic {
  ImageItem({required String path}) : super(path);

  static Future<List<ImageItem>> getImages() async {
    var storageFiles = _storageFiles(await StoragePath.imagesPath);
    List<ImageItem> items = [];
    for (int i = 0; i < storageFiles.length; i++) {
      for (int j = 0; j < storageFiles[i].files.length; j++) {
        var f = storageFiles[i].files[j];
        ImageItem item = ImageItem(path: f);
        items.add(item);
      }
    }
    return items;
  }
}

class FileItem extends FileBasic {
  FileItem({required String path}) : super(path);

  static Future<List<String>> getFiles() async {
    try {
      var storageFiles = await StoragePath.filePath;
      List<dynamic> filesPath = json.decode(storageFiles);
      List<String> result = [];
      for (var path in filesPath) {
        result.add(path.toString());

      }
      return result;
    } catch (e) {
      GetIt.I.get<Logger>().e(e);
      return [e.toString()];
    }
  }
}
