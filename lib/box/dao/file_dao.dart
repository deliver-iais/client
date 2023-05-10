import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/isar/file_info_isar.dart';
import 'package:isar/isar.dart';

abstract class FileDao {
  Future<FileInfo?> get(String uuid, String sizeType);

  Future<void> save(FileInfo fileInfo);

  Future<void> remove(FileInfo fileInfo);
}

class FileDaoImpl extends FileDao {
  @override
  Future<FileInfo?> get(String uuid, String sizeType) async {
    if (uuid.isEmpty) {
      return null;
    }
    final box = await _openFileInfoIsar();
    return box.fileInfoIsars
        .filter()
        .sizeTypeEqualTo(sizeType)
        .uuidEqualTo(uuid)
        .build()
        .findFirstSync()
        ?.fromIsar();
  }

  @override
  Future<void> save(FileInfo fileInfo) async {
    final box = await _openFileInfoIsar();
    box.writeTxnSync(() {
      box.fileInfoIsars.putSync(fileInfo.toIsar());
    });
  }

  @override
  Future<void> remove(FileInfo fileInfo) async {
    final box = await _openFileInfoIsar();
    final query = box.fileInfoIsars
        .filter()
        .sizeTypeEqualTo(fileInfo.sizeType)
        .uuidEqualTo(fileInfo.uuid)
        .build();
    return box.writeTxnSync(() {
      query.deleteAllSync();
    });
  }

  Future<Isar> _openFileInfoIsar() => IsarManager.open();
}
