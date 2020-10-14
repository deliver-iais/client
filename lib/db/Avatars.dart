import 'package:moor/moor.dart';

class Avatars extends Table {
  TextColumn get uid => text()();

  DateTimeColumn get createdOn => dateTime()();

  TextColumn get fileId => text()();

  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {uid, createdOn};
}
