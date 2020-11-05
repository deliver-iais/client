import 'package:moor/moor.dart';
import '../FileInfo.dart';
import '../database.dart';

part 'FileDao.g.dart';

@UseDao(tables: [FileInfos])
class FileDao extends DatabaseAccessor<Database> with _$FileDaoMixin {
  final Database database;

  FileDao(this.database) : super(database);

  Future upsert(FileInfo file) => into(fileInfos).insertOnConflictUpdate(file);

  Future deleteAvatar(FileInfo file) => delete(fileInfos).delete(file);

  Future<FileInfo> getFileInfo(id, size) {
    return (select(fileInfos)
          ..where((file) =>
              file.uuid.equals(id) & file.compressionSize.equals(size)))
        .getSingle();
  }
}
