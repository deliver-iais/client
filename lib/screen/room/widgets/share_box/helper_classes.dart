import 'dart:convert';
import 'dart:io';

import 'package:deliver/services/storage_path.dart';



class StorageFile {
  final List files;
  final String folderName;

  StorageFile({required this.files, required this.folderName});

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

class AudioItem extends FileBasic {
  final String title;

  AudioItem({required String path, required this.title}) : super(path);

  static Future<List<File>> getAudios() async {
    return[];
    //Todo read all audio file
    // List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    // List<File> files = [];
    // for (var s in storageInfo) {
    //   var root =
    //       s.rootDir; //storageInfo[1] for SD card, geting the root directory
    //   var fm = FileManager(root: Directory(root)); //
    //   List<File> f = await fm.filesTree(extensions: ["mp3"]);
    //   files.addAll(f);
    // }
    // return files;
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
