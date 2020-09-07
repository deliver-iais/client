import 'package:moor/moor.dart';

class Avatars extends Table {
  TextColumn get uid => text()();

  TextColumn get fileId => text()();

  IntColumn get date => integer()();

  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {fileId};
}
