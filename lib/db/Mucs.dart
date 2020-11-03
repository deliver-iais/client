import 'package:moor/moor.dart';

class Mucs extends Table {

  TextColumn get uid => text()();

  TextColumn get name => text()();

  TextColumn get info => text().nullable()();

  IntColumn get members => integer()();

  @override
  Set<Column> get primaryKey => {uid};
}
