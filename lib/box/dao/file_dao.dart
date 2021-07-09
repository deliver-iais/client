import 'package:deliver_flutter/box/file_info.dart';
import 'package:hive/hive.dart';

abstract class FileDao {
  Future<FileInfo> get(String uuid, String sizeType);

  Future<void> save(FileInfo fileInfo);

  Future<void> remove(FileInfo fileInfo);
}

class FileDaoImpl implements FileDao {
  Future<FileInfo> get(String uuid, String sizeType) async {
    var box = await _open(sizeType);

    return box.get(uuid);
  }

  Future<void> save(FileInfo fileInfo) async {
    var box = await _open(fileInfo.sizeType);

    box.put(fileInfo.uuid, fileInfo);
  }

  Future<void> remove(FileInfo fileInfo) async {
    var box = await _open(fileInfo.sizeType);

    box.delete(fileInfo.uuid);
  }

  static String _key(String size) => "file-info-$size";

  static Future<Box<FileInfo>> _open(String size) =>
      Hive.openBox<FileInfo>(_key(size));
}
