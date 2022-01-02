import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/file_info.dart';
import 'package:hive/hive.dart';

abstract class FileDao {
  Future<FileInfo?> get(String uuid, String sizeType);

  Future<void> save(FileInfo fileInfo);

  Future<void> remove(FileInfo fileInfo);
}

class FileDaoImpl implements FileDao {
  @override
  Future<FileInfo?> get(String uuid, String sizeType) async {
    var box = await _open(sizeType);

    if (uuid.isEmpty) {
      return null;
    }

    return box.get(uuid);
  }

  @override
  Future<void> save(FileInfo fileInfo) async {
    var box = await _open(fileInfo.sizeType);

    box.put(fileInfo.uuid, fileInfo);
  }

  @override
  Future<void> remove(FileInfo fileInfo) async {
    var box = await _open(fileInfo.sizeType);

    box.delete(fileInfo.uuid);
  }

  static String _key(String size) => "file-info-$size";

  static Future<Box<FileInfo>> _open(String size) {
    BoxInfo.addBox(_key(size));
    return Hive.openBox<FileInfo>(_key(size));
  }
}
