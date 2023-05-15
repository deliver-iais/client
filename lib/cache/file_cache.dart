import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/shared/methods/blob.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:get_it/get_it.dart';
import 'package:universal_html/html.dart' as html;

class FileInfoCache {
  final Map<String, html.Blob> _webBlobFileCache = {};
  final _fileDao = GetIt.I.get<FileDao>();

  Future<String>? _getFilePathFromWebCache(
    String uuid, {
    String? size,
    bool ConvertToDataByte = false,
  }) {
    final blob = _webBlobFileCache[_createWebBlobKey(uuid, size: size)];
    if (blob != null) {
      if (ConvertToDataByte) {
        return getDataByteFromBlob(blob);
      } else {
        return Future.value(convertBlobToBlobUrl(blob));
      }
    }
    return null;
  }

  html.Blob? _getBlobFileFromWebCache(
    String uuid, {
    String? size,
  }) {
    return _webBlobFileCache[_createWebBlobKey(uuid, size: size)];
  }

  String _createWebBlobKey(
    String uuid, {
    String? size,
  }) =>
      uuid + (size ?? "real");

  void _deleteWebBlob(
    String uuid, {
    String? size,
  }) {
    _webBlobFileCache.remove(_createWebBlobKey(uuid, size: size));
  }

  String? _saveWebBlobToWebCache(
    html.Blob blob,
    String uuid, {
    String? size,
  }) {
    _webBlobFileCache[_createWebBlobKey(uuid, size: size)] = blob;
    return convertBlobToBlobUrl(
      blob,
    );
  }

  Future<void> _deleteFileInfo(String size, String uuid) async =>
      isWeb ? _deleteWebBlob(uuid, size: size) : _fileDao.remove(size, uuid);

  ///returned path is actual file path in native devices and blob url in web
  Future<String?>? getFilePath(
    String size,
    String uuid, {
    bool convertToDataByteInWeb = false,
  }) async =>
      isWeb
          ? await _getFilePathFromWebCache(
              uuid,
              size: size,
              ConvertToDataByte: convertToDataByteInWeb,
            )
          : (await _fileDao.get(uuid, size))?.path;

  /// file path is path in native devices and data byte in web
  Future<String?> saveFileInfo(
    String fileId,
    String filePath,
    String name,
    String sizeType,
  ) async {
    if (isWeb) {
      final blob = convertDataByteToBlob(filePath, name.getMimeString());
      final path = _saveWebBlobToWebCache(blob, fileId, size: sizeType);
      return path;
    }
    final fileInfo = FileInfo(
      uuid: fileId,
      name: name,
      path: filePath,
      sizeType: sizeType,
    );
    await _fileDao.save(fileInfo).then((value) => fileInfo);
    return fileInfo.path;
  }

  Future<void> updateFileInfoUuid(
    String uploadKey,
    String uuid,
    String name,
    String size,
    String filePath,
  ) async {
    if (isWeb) {
      final blob = _getBlobFileFromWebCache(uploadKey, size: size);
      await _deleteFileInfo(uploadKey, size);
      _saveWebBlobToWebCache(blob!, uuid, size: size);
    } else {
      await _deleteFileInfo(uploadKey, size);
      await saveFileInfo(uuid, filePath, name, size);
    }
  }
}
