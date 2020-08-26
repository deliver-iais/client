import 'package:moor/moor.dart';

class FileInfos extends Table {
  TextColumn get uuid => text()();

  TextColumn get path => text()();

  TextColumn get fileName => text()();

  TextColumn get size => text()();

  @override
  Set<Column> get primaryKey => {uuid, size};
}
