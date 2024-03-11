import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_video_info/flutter_video_info.dart';

import 'package:deliver/box/meta_type.dart' as meta;
import 'package:deliver/models/file.dart' as file_model;
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as file_proto;
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';

String normalizePath(String path) =>
    isWeb ? path : p.normalize(path).replaceAll("\\", "/");

String trimRecorderSavedPath(String path) => p.prettyUri(path);

String _normalizePath(String path) => p.normalize(path).replaceAll("\\", "/");

String getFileExtension(String path) =>
    p.extension(path).substring(1).toLowerCase();

String getFileName(String path) => p.basename(path);

int getFileSizeSync(String path) => File(path).lengthSync();

Size getImageDimension(String path) => isWeb
    ? ImageSizeGetter.getSize(MemoryInput(UriData.parse(path).contentAsBytes()))
    : ImageSizeGetter.getSize(FileInput(File(path)));

file_model.File filePickerPlatformFileToFileModel(PlatformFile f) =>
    file_model.File(
      isWeb
          ? Uri.dataFromBytes(
              (Uint8List.fromList(f.bytes!)).toList(),
              mimeType: "application/${f.extension ?? "octet-stream"}",
            ).toString()
          : f.path ?? "",
      f.name,
      extension: f.extension,
      size: f.size,
    );

// TODO(bitbeter): Test this in all platforms
file_model.File pathToFileModel(String path) => file_model.File(
      normalizePath(path),
      getFileName(path),
      size: getFileSizeSync(path),
      extension: getFileExtension(path),
    );

file_model.File fileToFileModel(File file) => file_model.File(
      _normalizePath(file.path),
      getFileName(file.path),
      size: file.lengthSync(),
      extension: getFileExtension(file.path),
    );

Future<file_model.File> xFileToFileModel(XFile file) async => file_model.File(
      _normalizePath(file.path),
      getFileName(file.path),
      size: await file.length(),
      extension: getFileExtension(file.path),
    );

bool isFileNameMimeMatchFileType(String fileName, String fileType) =>
    fileName.getMimeString().getMimeMainType() == fileType.getMimeMainType();

String detectFileMimeByFileModel(file_model.File file) => isWeb
    ? _detectFileMimeByFilePathForWeb(file.name, file.path)
    : _detectFileMimeByFilePath(file.path);

String _detectFileMimeByFilePath(String? filePath) {
  final fileMainType = _detectFileTypeByNameAndContent(filePath);
  return fileMainType.mimeByName;
  // if (true || settings.inLocalNetwork.va) {
  //   return fileMainType.mimeByName;
  // } else if (fileMainType.hasSameMainType()) {
  //   return fileMainType.mimeByContent;
  // } else {
  //   return DEFAULT_FILE_TYPE;
  // }
}

String _detectFileMimeByFilePathForWeb(String? fileName, String? filePath) {
  final fileMainType =
      _detectFileTypeByNameAndContentForWeb(fileName, filePath);
  if (fileMainType.hasSameMainType()) {
    return fileMainType.mimeByContent;
  } else {
    return DEFAULT_FILE_TYPE;
  }
}

file_model.MimeByNameAndContent _detectFileTypeByNameAndContent(
  String? filePath,
) {
  final typeByContent = lookupMimeTypeFromPath(
    "no-file",
    headerBytes: File(filePath ?? "").readAsBytesSync(),
  );

  return file_model.MimeByNameAndContent(
    filePath.getMimeString(),
    typeByContent,
  );
}

file_model.MimeByNameAndContent _detectFileTypeByNameAndContentForWeb(
  String? fileName,
  String? filePath,
) {
  final typeByContent = lookupMimeTypeFromPath(
    "no-file",
    headerBytes: _getWebFileData(filePath!),
  );

  return file_model.MimeByNameAndContent(
    fileName.getMimeString(),
    typeByContent,
  );
}

Uint8List _getWebFileData(String fileByte) => Uint8List.fromList(
      const Base64Codec().decode(fileByte.split("base64,")[1]),
    );

String byteFormat(int bytes, {int decimals = 1}) {
  if (bytes == 0) {
    return '0.0 KB';
  }
  const k = 1024;
  final dm = decimals <= 0 ? 0 : 1;
  final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (log(bytes) / log(k)).floor();
  return ('${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}');
}

extension FileProtoExtensions on file_proto.File {
  bool isImageFileProto() =>
      isImageFileType(type) && isFileNameMimeMatchFileType(name, type);

  bool isWsFileProto() => name.endsWith(".ws");

  bool isVideoFileProto() =>
      isVideoFileType(type) && isFileNameMimeMatchFileType(name, type);

  bool isAudioFileProto() =>
      isAudioFileType(type) && isFileNameMimeMatchFileType(name, type);

  meta.MetaType findMetaTypeFromFileProto() {
    if (isImageFileProto() || isVideoFileProto()) {
      return meta.MetaType.MEDIA;
    } else if (isAudioFileProto()) {
      if (isVoiceFileProto()) {
        return meta.MetaType.AUDIO;
      } else {
        return meta.MetaType.MUSIC;
      }
    } else {
      return meta.MetaType.FILE;
    }
  }

  bool isVoiceFileProto() =>
      isAudioFileProto() && audioWaveform.data.isNotEmpty;

  bool isGifFileProto() => isImageFileType(type);

  bool isJsonFileProto() =>
      isJsonFileType(type) && isFileNameMimeMatchFileType(name, type);
}

extension MimeExtensions on String? {
  String getMimeMainType() {
    if (this == null) {
      return "";
    }

    final parts = this!.split("/");

    if (parts.isEmpty) {
      return "";
    }

    return parts[0];
  }

  String getMimeSubType() {
    if (this == null) {
      return "";
    }

    final parts = this!.split("/");

    if (parts.isEmpty) {
      return "";
    }

    return parts[1];
  }
}

extension MimeTypeOfFileName on String? {
  String getMimeString() {
    if (this == null || this!.trim().isEmpty) {
      return DEFAULT_FILE_TYPE;
    } else {
      return lookupMimeTypeFromPath(this!);
    }
  }

  MediaType getMediaType() {
    return MediaType.parse(getMimeString());
  }
}

bool isImageFileType(String fileType) {
  final lt = fileType.toLowerCase();

  return _isImageFileType(lt);
}

bool isCompressibleImageFileType(String fileType) {
  final lt = fileType.toLowerCase();

  return _isImageFileType(lt) &&
      !lt.contains("svg") &&
      !lt.contains("gif") &&
      !lt.contains("photoshop");
}

bool _isImageFileType(String lt) {
  return (lt.contains('image') ||
      lt.contains("png") ||
      lt.contains("jfif") ||
      lt.contains("webp") ||
      lt.contains("jpeg") ||
      lt.contains("jpg"));
}

bool isVideoFileType(String fileType) {
  final lt = fileType.toLowerCase();

  return !isImageFileType(fileType) && lt.contains('video');
}

bool isVideo(String path) => isVideoFileType(
      detectFileMimeByFileModel(
        file_model.File(
          path,
          getFileName(path),
        ),
      ),
    );

bool isAudioFileType(String fileType) {
  final lt = fileType.toLowerCase();

  return !isImageFileType(fileType) &&
          !isVideoFileType(fileType) &&
          lt.contains('audio') ||
      lt.contains("m4a") ||
      lt.contains("mp4") ||
      lt.contains("ogg") ||
      lt.contains("opus");
}

bool isJsonFileType(String fileType) {
  final lt = fileType.toLowerCase();
  return (lt.contains('json'));
}

bool isGifFileType(String fileType) {
  final lt = fileType.toLowerCase();
  return (lt.contains('gif'));
}

bool isWsFileType(String fileType) {
  final lt = fileType.toLowerCase();
  return (lt.endsWith("ws"));
}

enum AnimationType { JSON, WS, GIF, NONE }

AnimationType animationFileType(String fileType) {
  if (isGifFileType(fileType)) {
    return AnimationType.GIF;
  } else if (isWsFileType(fileType)) {
    return AnimationType.WS;
  } else if (isJsonFileType(fileType)) {
    return AnimationType.JSON;
  } else {
    return AnimationType.NONE;
  }
}

extension ImagePath on String {
  ImageProvider<Object> imageProvider({
    double scale = 1.0,
    Map<String, String>? headers,
    int? cacheWidth,
    int? cacheHeight,
    bool evict = false,
  }) {
    final imgP = ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      (isWeb
          ? NetworkImage(this, scale: scale, headers: headers)
          : FileImage(File(this), scale: scale)) as ImageProvider<Object>,
    );
    if (evict) {
      return imgP..evict();
    } else {
      return imgP;
    }
  }
}

String lookupMimeTypeFromPath(String path, {List<int>? headerBytes}) {
  return _deliverMimeTypeResolver.lookup(
        path,
        headerBytes: isWeb && path.startsWith("data:")
            ? UriData.parse(path).contentAsBytes()
            : headerBytes,
      ) ??
      DEFAULT_FILE_TYPE;
}

final _deliverMimeTypeResolver = MimeTypeResolver()
  ..addExtension("jfif", "image/jpeg");

void onShowInFolder(String path) {
  final shell = Shell();
  if (isWindowsNative) {
    shell.run('explorer.exe /select,"${path.replaceAll("/", "\\")}"');
  } else if (isLinuxNative) {
    shell.run('nautilus "$path"');
  } else if (isMacOSNative) {
    shell.run('open $path');
  }
}

Future<VideoData?> getVideoInfo(String path) async {
  try {
    var width = 0;
    var height = 0;

    final videoInfo = FlutterVideoInfo();
    final info = await videoInfo.getVideoInfo(path);
    if (info != null) {
      width = info.width!;
      height = info.height!;

      if (info.orientation != null &&
          (info.orientation! == 90 || info.orientation! == 270)) {
        info
          ..height = width
          ..width = height;
      }
      return info;
    }
  } catch (e) {}
  return null;
}

// TODO(bitbeter): Use these for later
// const List<String> videoFormats = [
//   '.mp4',
//   '.mov',
//   '.avi',
//   '.wmv',
//   '.3gp',
//   '.3gpp',
//   '.mkv',
//   '.flv'
// ];
// const List<String> imageFormats = [
//   '.jpeg',
//   '.png',
//   '.jpg',
//   '.gif',
//   '.webp',
//   '.tif',
//   '.heic'
// ];
