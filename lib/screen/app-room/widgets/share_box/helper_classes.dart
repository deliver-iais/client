import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
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

   Future<List<File>> getFiles() async {
    var _checkPermission = GetIt.I.get<CheckPermissionsService>();
    if(await _checkPermission.checkStoragePermission()){
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      List<File> files = List();
      for (var s in storageInfo) {
        try{
          var root =
              s.rootDir; //storageInfo[1] for SD card, geting the root directory
          var fm = FileManager(root: Directory(root)); //
          List<File> f = await fm
              .filesTree(extensions: ["pdf", "mp4", "pptx", "docx", "xlsx"]);
          files.addAll(f);
        }catch(e){
          debug(e.toString());
        }
        return files;
      }
    }

  }
}

class AudioItem extends FileBasic {
  final String title;

  AudioItem({String path, this.title}) : super(path);

  static Future<List<File>> getAudios() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    List<File> files = List();
    for (var s in storageInfo) {
      var root =
          s.rootDir; //storageInfo[1] for SD card, geting the root directory
      var fm = FileManager(root: Directory(root)); //
      List<File> f = await fm.filesTree(extensions: ["mp3"]);
      files.addAll(f);
    }
    return files;
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
