import 'dart:html';

import 'package:moor/moor.dart';
import '../Files.dart';
import '../database.dart';

part 'FileDao.g.dart';

@UseDao(tables: [Files])

class FileDao extends DatabaseAccessor<Database>with _$FileDaoMixin{
  final Database database;
  FileDao(this.database):super(database);

  Future insetAvatar (File file)=> into(files).insert(file);

  Future deleteAvatar (File file) => delete(files).delete(file);

  getFile(id)=>select(files)..where((tbl) => tbl.id.equals(id));
}