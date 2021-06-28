import 'package:moor/moor.dart';

class Mucs extends Table {

  TextColumn get uid => text()();

  TextColumn get name => text().nullable()();

  TextColumn get token => text().nullable()();

  TextColumn get id => text().nullable()();

  TextColumn get info => text().nullable()();

  TextColumn get pinMessagesId => text().nullable()();

  IntColumn get members => integer().nullable()();

  @override
  Set<Column> get primaryKey => {uid};
}
