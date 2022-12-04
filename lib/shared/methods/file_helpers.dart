import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:deliver/models/file.dart' as file_model;
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;

class NotAcceptableFile {
  final file_model.File file;
  final bool isEmpty;
  final bool hasExtraSize;
  final bool hasNotAcceptableExtension;

  const NotAcceptableFile(
    this.file, {
    this.isEmpty = false,
    this.hasExtraSize = false,
    this.hasNotAcceptableExtension = false,
  });

  NotAcceptableFile.fromPath(
    String path, {
    this.isEmpty = false,
    this.hasExtraSize = false,
    this.hasNotAcceptableExtension = false,
  }) : file = pathToFileModel(path);

  NotAcceptableFile.fromFile(
    File file, {
    this.isEmpty = false,
    this.hasExtraSize = false,
    this.hasNotAcceptableExtension = false,
  }) : file = fileToFileModel(file);
}

String normalizePath(String path) => p.normalize(path).replaceAll("\\", "/");

String getFileExtension(String path) =>
    p.extension(path).substring(1).toLowerCase();

String getFileName(String path) => p.basename(path);

int getFileSizeSync(String path) => File(path).lengthSync();

file_model.File filePickerPlatformFileToFileModel(PlatformFile f) =>
    file_model.File(
      isWeb
          ? Uri.dataFromBytes(
              (f.bytes ?? Uint8List(0)).toList(),
            ).toString()
          : f.path ?? "",
      f.name,
      extension: f.extension,
      size: f.size,
    );

file_model.File pathToFileModel(String path) => file_model.File(
      normalizePath(path),
      getFileName(path),
      size: getFileSizeSync(path),
      extension: getFileExtension(path),
    );

file_model.File fileToFileModel(File file) => file_model.File(
      normalizePath(file.path),
      getFileName(file.path),
      size: file.lengthSync(),
      extension: getFileExtension(file.path),
    );

Future<file_model.File> xFileToFileModel(XFile file) async => file_model.File(
      normalizePath(file.path),
      getFileName(file.path),
      size: await file.length(),
      extension: getFileExtension(file.path),
    );

bool isImageFileExtension(String extension) {
  final lt = extension.toLowerCase();

  return lt.contains('image') ||
      lt.contains("png") ||
      lt.contains("jfif") ||
      lt.contains("webp") ||
      lt.contains("jpeg") ||
      lt.contains("jpg");
}

bool isVideoFileExtension(String extension) {
  final lt = extension.toLowerCase();

  return !isImageFileExtension(extension) && lt.contains('video');
}

// TODO(bitbeter): add more details
bool isVoiceFilePath(String path) {
  return getFileExtension(path) == "m4a" || getFileExtension(path) == "ogg";
}

Iterable<NotAcceptableFile> getNotAcceptableFiles(
  Iterable<file_model.File> files,
) {
  return files
      .where(
        (file) =>
            fileIsEmpty(file) ||
            fileHasExtraSize(file) ||
            !isAcceptableFileExtension(file.extension ?? ""),
      )
      .map(
        (file) => NotAcceptableFile(
          file,
          hasExtraSize: fileHasExtraSize(file),
          isEmpty: fileIsEmpty(file),
          hasNotAcceptableExtension:
              !isAcceptableFileExtension(file.extension ?? ""),
        ),
      )
      .toList();
}

bool fileIsEmpty(file_model.File file) =>
    (file.size ?? 0) <= MIN_FILE_SIZE_BYTE;

bool fileHasExtraSize(file_model.File file) =>
    (file.size ?? 0) >= MAX_FILE_SIZE_BYTE;

bool isAcceptableFileExtension(String extension) {
  extension = extension.toLowerCase();
  return extension == "mp3" ||
      extension == "mp4" ||
      extension == "pdf" ||
      extension == "jpeg" ||
      extension == "jpg" ||
      extension == "apk" ||
      extension == "txt" ||
      extension == "doc" ||
      extension == "docx" ||
      extension == "zip" ||
      extension == "rar" ||
      extension == "webp" ||
      extension == "ogg" ||
      extension == "svg" ||
      extension == "csv" ||
      extension == "xls" ||
      extension == "gif" ||
      extension == "png" ||
      extension == "m4a" ||
      extension == "xml" ||
      extension == "pptx" ||
      extension == "xlsm" ||
      extension == "xlsx" ||
      extension == "crt" ||
      extension == "tgs" ||
      extension == "mkv" ||
      extension == "jfif" ||
      extension == "ico" ||
      extension == "wav" ||
      extension == "opus" ||
      extension == "pem" ||
      extension == "ipa" ||
      extension == "tar" ||
      extension == "gzip" ||
      extension == "psd" ||
      extension == "env" ||
      extension == "exe" ||
      extension == "json" ||
      extension == "html" ||
      extension == "css" ||
      extension == "scss" ||
      extension == "js" ||
      extension == "ts" ||
      extension == "java" ||
      extension == "kt" ||
      extension == "yaml" ||
      extension == "yml" ||
      extension == "properties" ||
      extension == "srt" ||
      extension == "py" ||
      extension == "conf" ||
      extension == "config" ||
      extension == "icns" ||
      extension == "dart" ||
      extension == "c" ||
      extension == "md" ||
      extension == "bmp" ||
      extension == "pom" ||
      extension == "jar" ||
      extension == "msi" ||
      extension == "webm";
}

String byteFormat(int bytes, {int decimals = 2}) {
  if (bytes == 0) return '0.0 KB';
  const k = 1024;
  final dm = decimals <= 0 ? 0 : decimals;
  final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (log(bytes) / log(k)).floor();
  return ('${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}');
}
