import 'package:moor/moor.dart';

class Avatars extends Table {
  TextColumn get uid => text()();

  IntColumn get createdOn => integer()();

  TextColumn get fileId => text()();

  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {uid, createdOn};
}
