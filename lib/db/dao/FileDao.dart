import 'package:moor/moor.dart';
import '../Files.dart';
import '../database.dart';

part 'FileDao.g.dart';

@UseDao(tables: [Files])

class FileDao extends DatabaseAccessor<Database>with _$FileDaoMixin{
  final Database database;
  FileDao(this.database):super(database);
}