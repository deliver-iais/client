import 'package:moor/moor.dart';

class FileInfos extends Table {
  TextColumn get id => text()();

  TextColumn get path => text()();

  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {id};
}
