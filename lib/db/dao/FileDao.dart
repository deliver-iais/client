

import 'package:moor/moor.dart';
import '../FileInfo.dart';
import '../database.dart';

part 'FileDao.g.dart';

@UseDao(tables: [FileInfos])

class FileDao extends DatabaseAccessor<Database>with _$FileDaoMixin{
  final Database database;
  FileDao(this.database):super(database);

  Future insetAvatar (FileInfo file)=> into(fileInfos).insert(file);

  Future deleteAvatar (FileInfo file) => delete(fileInfos).delete(file);

   Future<List<FileInfo> > getFile(id) {
     return (select(fileInfos)..where((file) => file.id.equals(id))).get();
   }
}