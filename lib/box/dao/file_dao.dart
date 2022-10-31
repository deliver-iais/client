import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class FileDao extends DBManager {
  Future<FileInfo?> get(String uuid, String sizeType);

  Future<void> save(FileInfo fileInfo);

  Future<void> remove(FileInfo fileInfo);
}

class FileDaoImpl extends FileDao {
  @override
  Future<FileInfo?> get(String uuid, String sizeType) async {
    final box = await _open(sizeType);

    if (uuid.isEmpty) {
      return null;
    }

    return box.get(uuid);
  }

  @override
  Future<void> save(FileInfo fileInfo) async {
    final box = await _open(fileInfo.sizeType);

    return box.put(fileInfo.uuid, fileInfo);
  }

  @override
  Future<void> remove(FileInfo fileInfo) async {
    final box = await _open(fileInfo.sizeType);

    return box.delete(fileInfo.uuid);
  }

  static String _key(String size) => "file-info-$size";

  Future<BoxPlus<FileInfo>> _open(String size) {
    super.open(_key(size), FILE_INFO);
    return gen(Hive.openBox<FileInfo>(_key(size)));
  }
}
