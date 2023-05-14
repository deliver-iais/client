import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/hive/file_info_hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FileInfoDaoImpl extends FileDao {
  @override
  Future<FileInfo?> get(String uuid, String sizeType) async {
    final box = await _open(sizeType);

    if (uuid.isEmpty) {
      return null;
    }

    return box.get(uuid)?.fromHive();
  }

  @override
  Future<void> save(FileInfo fileInfo) async {
    final box = await _open(fileInfo.sizeType);

    return box.put(fileInfo.uuid, fileInfo.toHive());
  }

  @override
  Future<void> remove(FileInfo fileInfo) async {
    final box = await _open(fileInfo.sizeType);

    return box.delete(fileInfo.uuid);
  }

  String _key(String size) => "file-info-$size";

  Future<BoxPlus<FileInfoHive>> _open(String size) {
    DBManager.open(
      _key(size),
      TableInfo.FILE_INFO_TABLE_NAME,
    );
    return gen(Hive.openBox<FileInfoHive>(_key(size)));
  }
}
