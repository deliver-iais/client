import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:storage_path/storage_path.dart';

class StorageFile {
  final List files;
  final String folderName;

  StorageFile({this.files, this.folderName});

  factory StorageFile.fromJson(Map<String, dynamic> json) {
    return new StorageFile(
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

class FileItem extends FileBasic {
  final String title;

  FileItem({String path, this.title}) : super(path);

  static Future<List<FileItem>> getFiles() async {
    var storageFiles = _storageFiles(await StoragePath.filePath);
    storageFiles.addAll(_storageFiles(await StoragePath.videoPath));

    List<FileItem> items = [];
    for (int i = 0; i < storageFiles.length; i++) {
      for (int j = 0; j < storageFiles[i].files.length; j++) {
        FileItem item = FileItem(
            path: storageFiles[i].files[j]["path"],
            title: storageFiles[i].files[j]["title"]??storageFiles[i].files[j]["displayName"] ??"Unknown");
        items.add(item);
      }
    }
    print(items.length.toString());
    return items;

  }
}

class AudioItem extends FileBasic {
  final String title;

  AudioItem({String path, this.title}) : super(path);

  static Future<List<AudioItem>> getAudios() async {
    var storageFiles = _storageFiles(await StoragePath.audioPath);
    List<AudioItem> items = [];
    Fimber.d("pashmak");
    for (int i = 0; i < storageFiles.length; i++) {
      for (int j = 0; j < storageFiles[i].files.length; j++) {
        var f = storageFiles[i].files[j];
        AudioItem item = AudioItem(
            path: f["path"],
            title: f["displayName"] ?? f["album"] ?? f["artist"] ?? "Unknown");
        items.add(item);
      }
    }
    return items;
  }
}

class ImageItem extends FileBasic {
  ImageItem({String path}) : super(path);

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
