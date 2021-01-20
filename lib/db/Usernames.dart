import 'package:moor/moor.dart';

class Usernames extends Table {
  TextColumn get uid => text()();

  TextColumn get username => text().nullable()();

  Set<Column> get primaryKey => {uid};
}
