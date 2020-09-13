import 'package:moor/moor.dart';

class FileInfos extends Table {
  TextColumn get uuid => text()();

  TextColumn get compressionSize => text()();

  TextColumn get path => text()();

  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {uuid, compressionSize};
}
