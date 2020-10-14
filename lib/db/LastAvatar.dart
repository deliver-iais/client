import 'package:moor/moor.dart';

class LastAvatars extends Table {
  TextColumn get uid => text()();

  DateTimeColumn get createdOn => dateTime().nullable()();

  TextColumn get fileId => text().nullable()();

  TextColumn get fileName => text().nullable()();

  IntColumn get lastUpdate => integer()();

  @override
  Set<Column> get primaryKey => {uid};
}